build-gems
==========

Builds all gems in gem-list

- Based on https://github.com/KrisBuytaert/build-gems 
- Builds all dependencies as individual rpms
- Works around fpm bug where you can't specify gem version (Github fpm bug #204)
- Doesn't bother rebuilding gems in gem-list which have been built before
