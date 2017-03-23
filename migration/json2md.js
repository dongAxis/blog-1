var fs = require('fs');

const postTemplate = (meta, content) => `
<!--
${meta}
-->

${content}
`.trim();

const parseJsonFile = (filename) => JSON.parse(fs.readFileSync(filename).toString());

// TODO: https://html.spec.whatwg.org/multipage/syntax.html#named-character-references
const unescape = (str) => {
};

const posts = parseJsonFile('wp_posts.json');
const termRelationships = parseJsonFile('wp_term_relationships.json');
const terms = parseJsonFile('wp_terms.json');

function getTags(post) {
  return (
    termRelationships
    .filter((rel) => post.ID == rel.object_id)
    .map((rel) => terms.find((term) => term.term_id == rel.term_taxonomy_id).slug)
  );
}

const getFilename = (post) => {
  var prefix = '../src/posts/';
  var suffix = '.md';
  var name = post.post_name || (
    post.post_title.replace(/[^a-z0-9]/gi, '-').toLowerCase()
  );
  return prefix + post.post_date.slice(0, 10) + '-' + name + suffix;
}

function createPost(post) {
  const meta = {
    title: post.post_title,
    date: post.post_date,
    category: '',
    tags: getTags(post).filter(tag => tag !== 'uncategorized'),
    draft: post.post_status == 'draft'
  };
  const content = post.post_content_filtered;
  const metaStr = JSON.stringify(meta, null, 2);
  const filename = getFilename(post);
  fs.writeFileSync(filename, postTemplate(metaStr, content));
}

function selectPosts() {
  return (
    posts.filter((post) =>
      post.post_status == 'publish' || post.post_status == 'draft'
    )
  );
}

function main() {
  selectPosts()
  .forEach(createPost);
}

main();
