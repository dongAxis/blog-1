<!--
{
  "title": "Docker Compose Wordpress",
  "date": "2016-07-02T18:50:32.000Z",
  "category": "",
  "tags": [
    "wordpress",
    "docker"
  ],
  "draft": false
}
-->

I've used wordpress as my Ops playground. Wordpress has interesting characteristics as web application (e.g. theme/plugins are persisted in file system), so that drives me to try more and more tools.

Actually, I've made three versions of production deployment setup:

1. ansible and capistrano
2. ansible and docker/docker-compose
3. docker/docker-compose (https://github.com/hi-ogawa/docker-compose-wordpress)

Finally, it turned out docker/docker-compose (and a couple of 3rd-party docker images) suffices to do what I want, which is:

- Provide almost same environment on local experiment and remote server production
  - Differences are made only by `env.development` and `env.production` files
- Easy to update config files (e.g. `wp-config.php` or `apache2.conf`)
  - You only need `docker-compose restart wordpress` after those files are changed
- Easy to add system dependency of php app
  - You only need `docker-compose up --build wordpress` after `Dockerfile.wordpress` is changed
- Easy to backup/restore wordpress files and mysql data (and email notification email notification)
  - Backup whole docker volumes
  - Upload to s3 by using [dockerized aws sdk app](https://hub.docker.com/r/cgswong/aws/)
  - Call Mailgun API from `curl`

---

# What I Learnt

I will list a couple of things I learnt from this experience.

- Provide credential by using [docker-compose environment variable interpolation](https://github.com/hi-ogawa/docker-compose-wordpress/blob/781126123e7f0cb9782133a23a56feffdf2cafb9/docker-compose.yml#L8-L12)
- `restart: always` for restarting server app automatically:
  - https://docs.docker.com/v1.11/engine/reference/run/#restart-policies-restart

- `mem_limit` to control memory usage for each container:
  - https://docs.docker.com/v1.11/engine/reference/run/#runtime-constraints-on-resources

- Override `docker-compose.yml` to reuse base containers architecture
  - https://docs.docker.com/v1.11/compose/extends/#understanding-multiple-compose-files

- mount single files for configuration (`apache2.conf`, `wp-config.php`)
  - https://docs.docker.com/v1.11/engine/userguide/containers/dockervolumes/#mount-a-host-file-as-a-data-volume

- Named volume from `docker-compose`
  - https://docs.docker.com/v1.11/compose/compose-file/#volume-configuration-reference
  - https://docs.docker.com/v1.11/engine/reference/commandline/volume_create/

- Use `mysql:5.5` instead of `mysql:5.7` since `mysql:5.7` requires too much memory for my EC2 micro instance.
  - For comparison of default configuration:
      - `mysql:5.7`: starts from 200MB and goes to more than 500MB without any action
      - `mysql:5.5`: starts from 100MB and keep it

---

# Wordpress Theme Development

As another subject of wordpress, I like to customize theme and like to track those changes. I was using a wordpress plugin [Revisr](https://wordpress.org/plugins/revisr/) for this process.

As you can see from [my old post](http://wp.hiogawa.net/2016/04/29/wordpress-revisr-setup/) about how to setup Revisr, it's kinda complicated. So, I've wanted to find a simpler way and here is my new approach:

1. Create a fork of original theme
2. Develop and preview on local with docker-compose
3. Create a release from Github and download zip file
4. On production, uploading zip file and replace old one

I forked theme [twentyelven](https://wordpress.org/themes/twentyeleven/) into my repository https://github.com/hi-ogawa/wordpress-theme-twentyeleven and I'm using this theme here in my blog.