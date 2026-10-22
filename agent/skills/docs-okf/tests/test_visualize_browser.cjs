// Real browser regression for the generated HTML, run by test_visualize_security.py.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { chromium } = require('playwright');

async function main() {
  const html = fs.readFileSync(process.argv[2], 'utf8');
  const assets = process.env.OKF_VIZ_ASSETS;
  assert.ok(assets, 'OKF_VIZ_ASSETS must contain the pinned production CDN scripts');
  const browser = await chromium.launch({
    headless: true,
    ...(process.env.OKF_BROWSER_EXECUTABLE ? { executablePath: process.env.OKF_BROWSER_EXECUTABLE } : {}),
  });
  try {
    for (const mode of ['normal', 'missing-purifier', 'unsupported-purifier', 'throwing-purifier', 'missing-marked']) {
      const page = await browser.newPage();
      const errors = [];
      page.on('pageerror', error => errors.push(error.message));
      await page.route('**/*', route => {
        const url = route.request().url();
        if (url === 'https://okf.test/viz.html') {
          return route.fulfill({ contentType: 'text/html', body: html });
        }
        const dependency = url.includes('/cytoscape@') ? 'cytoscape.min.js'
          : url.includes('/marked') ? 'marked.min.js'
          : url.includes('/dompurify@') ? 'purify.min.js' : null;
        if (!dependency || (mode === 'missing-purifier' && dependency === 'purify.min.js') ||
            (mode === 'missing-marked' && dependency === 'marked.min.js')) {
          return route.abort();
        }
        return route.fulfill({
          contentType: 'application/javascript',
          headers: { 'access-control-allow-origin': '*' },
          body: fs.readFileSync(path.join(assets, dependency)),
        });
      });
      await page.goto('https://okf.test/viz.html');
      await page.waitForFunction(() => !!document.getElementById('cy')._cyreg?.cy);
      if (mode === 'unsupported-purifier') {
        await page.evaluate(() => { window.DOMPurify.isSupported = false; });
      } else if (mode === 'throwing-purifier') {
        await page.evaluate(() => { window.DOMPurify.sanitize = () => { throw new Error('sanitizer failed'); }; });
      }
      await page.evaluate(() => document.getElementById('cy')._cyreg.cy.getElementById('target').emit('tap'));
      const snapshot = await page.evaluate(() => {
        const data = JSON.parse(document.getElementById('okf-bundle-data').textContent);
        const detail = document.getElementById('detail');
        const body = detail.querySelector('.body');
        return {
          xss: window.__xss || 0,
          name: document.querySelector('header h1').textContent,
          title: document.title,
          expectedName: data.name,
          heading: detail.querySelector('h2')?.textContent,
          expectedTitle: data.concepts.target.title,
          metadataImages: document.querySelectorAll('header img, #legend img, #backlinks img, #detail > h2 img, .meta img, .tags img').length,
          backlinks: document.querySelector('#backlinks a')?.getAttribute('data-id'),
          expectedBacklink: data.concepts.target.backlinks[0],
          injectedAttributes: document.querySelectorAll('[data-injected]').length,
          body: body?.textContent,
          raw: data.concepts.target.body,
          childElements: body?.children.length,
          dangerousElements: body?.querySelectorAll('script, iframe, svg, [onerror], [onload]').length,
          dangerousLinks: [...(body?.querySelectorAll('a[href]') || [])].filter(a => /^(javascript|data):/i.test(a.getAttribute('href'))).length,
          bold: body?.querySelector('strong')?.textContent,
          https: body?.querySelector('a[href="https://example.com/path"]')?.textContent,
          mail: body?.querySelector('a[href="mailto:test@example.com"]')?.textContent,
          detailCount: document.querySelectorAll('#detail').length,
        };
      });
      assert.equal(snapshot.xss, 0, mode + ': script or event handler executed');
      assert.equal(snapshot.name, snapshot.expectedName, mode + ': name escaped incorrectly');
      assert.equal(snapshot.title, snapshot.expectedName, mode + ': document title escaped incorrectly');
      assert.equal(snapshot.heading, snapshot.expectedTitle, mode + ': metadata not literal');
      assert.equal(snapshot.metadataImages, 0, mode + ': metadata created elements');
      assert.equal(snapshot.backlinks, snapshot.expectedBacklink, mode + ': backlink id changed');
      assert.equal(snapshot.injectedAttributes, 0, mode + ': backlink attribute injection');
      assert.equal(snapshot.dangerousElements, 0, mode + ': active HTML survived');
      assert.equal(snapshot.dangerousLinks, 0, mode + ': unsafe URI survived');
      assert.equal(snapshot.detailCount, 1, mode + ': body clobbered application id');
      if (mode === 'normal') {
        assert.equal(snapshot.bold, 'Bold');
        assert.equal(snapshot.https, 'HTTPS');
        assert.equal(snapshot.mail, 'Mail');
        for (const label of ['bad', 'encoded']) {
          await page.locator('#detail .body a').filter({ hasText: new RegExp('^' + label + '$') }).click();
        }
        assert.equal(await page.evaluate(() => window.__xss || 0), 0, 'unsafe link executed after clicking');
        await page.locator('#detail .body a').filter({ hasText: /^Source$/ }).click();
        assert.equal(await page.locator('#detail h2').textContent(), 'Source');
        await page.locator('#detail .body a').filter({ hasText: /^Target$/ }).click();
      } else {
        assert.equal(snapshot.body, snapshot.raw, mode + ': expected lossless plain text fallback');
        assert.equal(snapshot.childElements, 0, mode + ': fallback created HTML');
      }
      await page.locator('#backlinks a').click();
      assert.equal(await page.locator('#detail .meta > div').first().textContent(), 'ID: ' + snapshot.expectedBacklink);
      assert.deepEqual(errors, [], mode + ': unexpected page errors');
      await page.close();
      console.log('PASS browser ' + mode);
    }
  } finally {
    await browser.close();
  }
}

main().catch(error => { console.error(error); process.exitCode = 1; });
