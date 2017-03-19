require 'json'
require 'listen'
require 'redcarpet'
require 'sass'
require 'slim'
require 'slim/include'
require 'time'

SRC_DIR = ENV['SRC']
OUT_DIR = ENV['OUT']

class Post
  attr_accessor :meta, :md_file, :md_str, :md_html_str, :html_file, :html_str, :link_path

  def extract_meta!
    if m = @md_str.match(/^<!--(.*?)-->/m)
      @meta = JSON.parse(m[1])
    end
  end

  def render_html!(slim_template)
    @md_html_str = Redcarpet::Markdown.new(Redcarpet::Render::HTML, fenced_code_blocks: true, autolink: true).render(@md_str)
    @html_str = Slim::Template.new(slim_template).render(self)
  end
end

class Index
  attr_accessor :posts, :html_str

  def render_html!(slim_template)
    @html_str = Slim::Template.new(slim_template).render(self)
  end
end

module Build
  class << self
    def main
      run
      if ENV['WATCH']
        listener = Listen.to(SRC_DIR) do
          run
        end
        listener.start
        sleep
      end
    end

    def run
      puts 'running'
      run_sass
      run_md_and_slim
    end

    def run_sass
      out_str = Sass::Engine.for_file(SRC_DIR + '/scss/index.scss', {}).render
      File.write(OUT_DIR + '/index.css', out_str)
    end

    def run_md_and_slim
      posts = process_posts
      process_index_html(posts)
    end

    def process_posts
      Pathname.new(SRC_DIR + '/posts').children.map do |md_file|
        p = Post.new
        p.md_file = md_file.basename.to_s
        p.md_str = File.read(md_file)
        p.extract_meta!
        p.link_path = '/posts/' + p.md_file.gsub('.md', '.html')
        p.html_file = OUT_DIR + p.link_path
        p.render_html!(SRC_DIR + '/slim/post.slim')
        File.write(p.html_file, p.html_str)
        p
      end
    end

    def process_index_html(posts)
      index = Index.new
      index.posts = posts
      index.render_html!(SRC_DIR + '/slim/index.slim')
      File.write(OUT_DIR + '/index.html', index.html_str)
    end
  end
end

Build.main
