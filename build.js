const fs = require('fs');
const process = require('process');
const showdown  = require('showdown');
const _ = require('lodash');

// Helpers
const readFile = (file) => fs.readFileSync(file).toString();
const template = (file, obj) => _.template(readFile(file))(obj);
const extractMeta = (mdFile) => {
  const meta = JSON.parse(readFile(mdFile).match(/^<!--([\s\S]*?)-->/m)[1]);
  meta.link = mdFile.replace(/^src/, '').replace('.md', '.html');
  return meta;
}

// Generate out/index.html
const processIndex = () => {
  const _postMetas = fs.readdirSync('src/posts').map((f) => extractMeta(`src/posts/${f}`));
  const postMetas = _.sortBy(_postMetas.filter(m => !m.special), (m => new Date(m.date))).reverse();
  const contentHtml = template('src/templates/_index.html', { postMetas });
  const html = template('src/templates/_entry.html', { content: contentHtml });
  fs.writeFileSync('out/index.html', html);
}

// Generate out/posts/<some-post>.html
const processPost = (mdFile) => {
  const mdStr = readFile(mdFile);
  const mdHtml = (new showdown.Converter({
    simplifiedAutoLink: true,
    excludeTrailingPunctuationFromURLs: true,
    disableForced4SpacesIndentedSublists: true,
    parseImgDimensions: true
  })).makeHtml(mdStr);
  const meta = extractMeta(mdFile);
  const contentHtml = template('src/templates/_post.html', { meta, mdHtml });
  const html = template('src/templates/_entry.html', { content: contentHtml });
  const outHtmlFile = mdFile.replace(/^src/, 'out').replace('.md', '.html');
  fs.writeFileSync(outHtmlFile, html);
}

// Main
(() => {
  switch (process.argv[2]) {
    case 'index': {
      return processIndex();
    }
    case 'post': {
      return processPost(process.argv[3]);
    }
  }
})();

