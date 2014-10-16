discourse-embed-by-topic-id
===========================

Discourse plugin that lets you embed discussions by topic ID or topic URL.

Discourse embedding allows you to [use Discourse as a comment system](http://eviltrout.com/2014/01/22/embedding-discourse.html) for another website. It identifies the 'thread' of the discussion based on a raw URL, so your discussion has to start on the embedding website. This plugin lets you embed an existing discussion into a website by including the Discourse topic id or path portion of the topic URL.

Usage
=====

1. Install this plugin into Discourse.
2. Setup normal embedding as per http://eviltrout.com/2014/01/22/embedding-discourse.html
3. Set the `discourseEmbedUrl` variable:

If your Discourse topic URL is `http://discourse.example.com/t/do-you-have-a-job/43/4` then your topic id is `43`.

```javascript
discourseEmbedUrl = '43';
```
or
```javascript
discourseEmbedUrl = '/t/do-you-have-a-job/43/4';
```
