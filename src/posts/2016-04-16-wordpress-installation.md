<!--
{
  "title": "Wordpress Installation",
  "date": "2016-04-16T00:46:34.000Z",
  "category": "",
  "tags": [
    "ansible",
    "wordpress"
  ],
  "draft": false
}
-->

Currently, I setup [my blog](http://blog.hiogawa.net) by using [ghost](https://ghost.org/) on heroku .

<span style="line-height: 1.6471;">Since I've helped setting up [wordpress for my company](http://blog.odigo.travel/), I understand wordpress is much better/powerful to use. So I decided to use for myself as well.</span>

<span style="line-height: 1.6471;">As I used heroku for ghost blog, I could try heroku for wordpress, but for now I'm using AWS since I don't get used to heroku yet. Maybe I'll try setting up on heroku in the futre. it looks like there's good stuff for that purpose already: https://github.com/mhoofman/wordpress-heroku.</span>

For company blog, I'm using [capistrano](http://capistranorb.com/) and [ansible](http://docs.ansible.com/ansible/) for continuous deployment. <span style="line-height: 1.6471;">For my use case, I believe it's enough to setting up once and for all with ansible.</span>

<span style="line-height: 1.6471;">The repository for company blog and its deployment scripts are not public, but this ansible script for setting up this website in on my public repository ([hi-ogawa/wordpress_ansible](https://github.com/hi-ogawa/wordpress_ansible)).</span>