# 标准 awk；仅识别本模板使用的 frontmatter、ATX 标题、注释与围栏。
# 不解释完整 YAML，也不代替业务、依赖环、来源真实性等人工审查。
function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
function warning(s) { print "[WARN]  " name ": " s }
function failure(s) { print "[ERROR] " name ": " s }
function uncomment(s,    out, p) {
    out = ""
    while (length(s)) {
        if (comment) {
            p = index(s, "-->")
            if (!p) return out
            s = substr(s, p + 3); comment = 0
        } else {
            p = index(s, "<!--")
            if (!p) return out s
            out = out substr(s, 1, p - 1); s = substr(s, p + 4); comment = 1
        }
    }
    return out
}
function fence_line(s,    run, rest) {
    s = trim(s)
    if (s !~ /^```/ && s !~ /^~~~/) return 0
    run = s; sub(/[^`~].*$/, "", run)
    if (fence) {
        rest = substr(s, length(run) + 1)
        if (substr(run, 1, 1) == fence && length(run) >= fence_size && trim(rest) == "") {
            fence = ""; return 1
        }
        return 0
    }
    fence = substr(run, 1, 1); fence_size = length(run); return 1
}
function heading(s) {
    s = trim(s)
    if (s !~ /^#{1,6}[ \t]+/) return ""
    sub(/[ \t]+#+[ \t]*$/, "", s)
    sub(/[ \t]+$/, "", s)
    return s
}
function scalar(s,    q, i, tail) {
    s = trim(s)
    q = substr(s, 1, 1)
    if (q == "\"" || q == "\047") {
        # 支持单行引号标量及尾部注释，不进行转义解码。
        for (i = 2; i <= length(s); i++) {
            if (q == "\"" && substr(s, i, 1) == "\\") { i++; continue }
            if (substr(s, i, 1) != q) continue
            if (q == "\047" && substr(s, i + 1, 1) == q) { i++; continue }
            tail = trim(substr(s, i + 1))
            if (tail == "" || tail ~ /^#/) return substr(s, 2, i - 2)
            return ""
        }
        return ""
    }
    sub(/[ \t]+#.*/, "", s)
    s = trim(s)
    if (s ~ /^[\[{|>#]/ || tolower(s) == "null" || s == "~") return ""
    return s
}
function reference_label(s) { s = trim(s); gsub(/[ \t]+/, " ", s); return tolower(s) }
function context_cell(s) {
    s = trim(s)
    gsub(/[`*_]/, "", s)
    if (s ~ /^\[[^][]+\](\([^)]*\)|\[[^][]*\])?$/) {
        sub(/^\[/, "", s); sub(/\].*$/, "", s)
    }
    return trim(s)
}
function inspect_context(s,    cells, count, i, header_column) {
    if (s !~ /^[ \t]*\|/) { context_column = 0; return }
    count = split(s, cells, "|")
    for (i = 1; i <= count; i++) if (context_cell(cells[i]) == "决策编号") header_column = i
    if (header_column) { context_column = header_column; return }
    if (context_column && context_cell(cells[context_column]) == adr_id) registered = 1
}
# 常用单行 Markdown 链接：内联/引用式、尖括号目标及可选标题。
# 这里只提取目标；Bash 层负责相对于文档路径解析并核对实际台账文件。
function link_destination(s, inline,    destination, end, tail, quote, close_quote) {
    s = trim(s)
    if (substr(s, 1, 1) == "<") {
        end = index(s, ">")
        if (!end) return ""
        destination = substr(s, 2, end - 2); tail = trim(substr(s, end + 1))
    } else {
        if (!match(s, /^[^ \t)]+/)) return ""
        destination = substr(s, 1, RLENGTH); tail = trim(substr(s, RLENGTH + 1))
    }
    if ((inline && substr(tail, 1, 1) == ")") || (!inline && tail == "")) return destination
    quote = substr(tail, 1, 1)
    if (quote != "\"" && quote != "\047" && quote != "(") return ""
    close_quote = quote == "(" ? ")" : quote
    end = index(substr(tail, 2), close_quote)
    if (!end) return ""
    tail = trim(substr(tail, end + 2))
    if ((inline && substr(tail, 1, 1) == ")") || (!inline && tail == "")) return destination
    return ""
}
function collect_links(s,    label, tail, destination, rest, length_used, offset, explicit_label) {
    gsub(/`+[^`]*`+/, "", s)
    if (match(s, /^[ \t]*\[[^][]+\]:[ \t]*/)) {
        length_used = RLENGTH
        label = substr(s, index(s, "[") + 1); sub(/\].*$/, "", label)
        references[reference_label(label)] = link_destination(substr(s, length_used + 1), 0)
        return
    }
    rest = s
    while (match(rest, /\[[^][]*\]\(/)) {
        offset = RSTART; length_used = RLENGTH
        tail = substr(rest, offset + length_used)
        destination = link_destination(tail, 1)
        if (destination != "" && (offset == 1 || substr(rest, offset - 1, 1) != "!")) links[destination] = 1
        rest = tail
    }
    rest = s
    while (match(rest, /\[[^][]+\]/)) {
        offset = RSTART; length_used = RLENGTH
        label = substr(rest, offset + 1, length_used - 2)
        tail = substr(rest, offset + length_used)
        if ((offset == 1 || substr(rest, offset - 1, 1) != "!") && substr(tail, 1, 1) != "(") {
            if (match(tail, /^[ \t]*\[[^][]*\]/)) {
                length_used = RLENGTH
                explicit_label = substr(tail, index(tail, "[") + 1); sub(/\].*$/, "", explicit_label)
                if (explicit_label != "") label = explicit_label
                tail = substr(tail, length_used + 1)
            }
            used_references[reference_label(label)] = 1
        }
        rest = tail
    }
}
function add_content(s,    i, cell, cells, count, meaningful) {
    s = trim(s)
    if (s == "" || s ~ /^[-*_][ \t]*[-*_][ \t]*[-*_][-*_ \t]*$/) { table = 0; return }
    if (s ~ /^\|/) {
        if (!table) { table = 1; return }
        count = split(s, cells, "|"); meaningful = 0
        for (i = 1; i <= count; i++) {
            cell = trim(cells[i])
            if (cell != "" && cell !~ /^:?-+:?$/ && cell !~ /^[GQCR]-[0-9]+$/) meaningful = 1
        }
        if (!meaningful) return
    } else table = 0
    for (i = 1; i <= 6; i++) if (active[i]) content[active[i]] = 1
}
function has_milestone(s,    rest, tail, closing) {
    if (s ~ /(^|[^A-Za-z0-9_])M[0-9]+\([^)]+\)/) return 1
    rest = s
    # C locale 下不能用 [^）]：它排除的是三个字节，会误伤正常汉字。
    while (match(rest, /(^|[^A-Za-z0-9_])M[0-9]+（/)) {
        tail = substr(rest, RSTART + RLENGTH)
        closing = index(tail, "）")
        if (closing > 1) return 1
        rest = tail
    }
    return 0
}
function inspect_text(s, is_code,    i, rest, token, before, after) {
    add_content(s)
    if (!internal) {
        for (i = 1; i <= term_count; i++) {
            if (index(s, terms[i])) technical[terms[i]]++
        }
    }
    if (is_code) return
    if (s ~ /(^|[^A-Za-z0-9_-])G-[0-9]+([^0-9]|$)/) goals++
    if (milestone_section && has_milestone(s)) milestones++
    collect_links(s)
    if (index(s, "ADR-待定")) pending = 1
    rest = s
    while (match(rest, /ADR-[0-9]+/)) {
        token = substr(rest, RSTART, RLENGTH)
        before = RSTART > 1 ? substr(rest, RSTART - 1, 1) : ""
        after = substr(rest, RSTART + RLENGTH, 1)
        if (before !~ /[A-Za-z0-9_]/ && after !~ /[A-Za-z0-9_]/) adrs[token] = 1
        rest = substr(rest, RSTART + RLENGTH)
    }
}
BEGIN {
    if (mode != "context") {
        template_line = 0
        while ((getline line < template) > 0) {
            sub(/\r$/, "", line); template_line++
            if (template_line == 1 && line == "---") { template_front = 1; continue }
            if (template_front) {
                if (line == "---") { template_front = 0; continue }
                if (line ~ /^[A-Za-z_][A-Za-z0-9_-]*:/) {
                    field = line; sub(/:.*/, "", field); required_fields[++field_count] = field
                }
                continue
            }
            if (fence) { fence_line(line); continue }
            line = uncomment(line)
            if (fence_line(line)) continue
            h = heading(line)
            if (h ~ /^#{2,4} /) { expected[++expected_count] = h; position[h] = expected_count }
        }
        close(template)
        comment = 0; fence = ""
        if (!expected_count || !field_count) failure("模板缺少标题或元字段")
        term_count = split("Spring Boot|Kafka|Redis|TiDB|MySQL|Dubbo|RPC|MQ|MyBatis|Docker|Kubernetes", terms, "|")
    }
}
{
    sub(/\r$/, "")
    if (mode != "context") {
        if (NR == 1) {
            if ($0 == "---") { front = 1; next }
            failure("缺少文首 frontmatter（首行应为 ---）")
        }
        if (front) {
            if ($0 == "---") { front = 0; closed_front = 1; next }
            if ($0 ~ /^[A-Za-z_][A-Za-z0-9_-]*:/) {
                key = $0; sub(/:.*/, "", key)
                value = $0; sub(/^[^:]*:/, "", value)
                if (key in metadata) warning("重复元字段: " key)
                metadata[key] = scalar(value)
            }
            next
        }
    }
    if (fence) {
        if (!fence_line($0) && mode != "context") inspect_text($0, 1)
        next
    }
    line = uncomment($0)
    if (fence_line(line)) next
    if (mode == "context") {
        inspect_context(line)
        next
    }
    h = heading(line)
    if (h != "") {
        hashes = h; sub(/[ \t].*/, "", hashes); level = length(hashes)
        if (level <= 3) { internal = h ~ /^### 7[.]3 /; milestone_section = h ~ /^### 6[.]1 / }
        for (j = level; j <= 6; j++) active[j] = 0
        if (h in position) {
            if (seen[h]++) warning("重复标题: " h)
            if (position[h] < previous_position) warning("标题顺序异常: " h)
            previous_position = position[h]; active[level] = h
        }
        table = 0
        next
    }
    inspect_text(line, 0)
}
END {
    if (mode == "context") exit !registered
    if (NR == 0) failure("缺少文首 frontmatter（空文件）")
    if (front) failure("frontmatter 未闭合（缺少第二个 ---）")
    if (closed_front) {
        for (i = 1; i <= field_count; i++) {
            field = required_fields[i]
            if (!(field in metadata)) warning("缺少 " field ": 字段")
            else if (field != "parent" && field != "dependencies" && field != "tags" && metadata[field] == "") warning("元字段为空或不是单行标量: " field)
        }
        file_id = name; sub(/[.]md$/, "", file_id)
        if (metadata["id"] != file_id || metadata["id"] !~ /^ANALYSIS-.+/) warning("id 与文件名不一致: " metadata["id"])
        if (metadata["status"] !~ /^(draft|review|approved)$/) warning("status 值异常: " metadata["status"])
    }
    for (i = 1; i <= expected_count; i++) {
        h = expected[i]
        if (!seen[h]) warning((h ~ /^## / ? "缺少章节: " : "缺少小节标题: ") h)
        else if (!content[h]) warning("章节/小节无内容且未标注「不适用」或「待补充」: " h)
    }
    if (!goals) warning("未发现业务目标编号 (G-n)")
    if (!milestones) warning("§6.1 未发现 M{n}（短名）写法")
    for (i = 1; i <= term_count; i++) if (technical[terms[i]]) warning("业务正文中发现技术词「" terms[i] "」(" technical[terms[i]] " 处)")
    for (token in adrs) print "ADR\t" token
    for (label in used_references) if (references[label] != "") links[references[label]] = 1
    for (destination in links) print "CONTEXT\t" destination
    if (pending) print "PENDING\t1"
}
