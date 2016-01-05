---
layout: page
title: Documentation
permalink: /documentation/
thin_site_title: true
---

`teepee` has plenty of documentation... including this very site.

## Manual

You can access different levels of documentation just invoking `teepee`
in the right way:

- `teepee --usage` provides you a list of the available options
- `teepee --help` provides you the list above, plus an explanation of
  each option
- `teepee --man` lets you read the manual

You can also read the manual for the latest release online in the
[README.md](https://github.com/polettix/teepee/blob/master/README.md)
file for [GitHub repository for
`teepee`](https://github.com/polettix/teepee/).

## Articles

<ul class="post-list">
{% for post in site.categories.articles %} 
  <li><article><a href="{% if post.link %}{{ post.link }}{% else %}{{ site.url }}{{ post.url }}{% endif %}">{{ post.title }} <span class="entry-date"><time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date: "%B %d, %Y" }}</time></span>{% if post.excerpt %} <span class="excerpt">{{ post.excerpt }}</span>{% endif %}</a></article></li>
{% endfor %}
</ul>
