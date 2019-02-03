---
layout: homepage
title: 'Welcome'
search_omit: true
---

 `teepee` allows you to generate data according to a template. Data is
 extracted from data structures available in JSON or YAML format, read from
 files or from standard input. This should make it easy to extract the needed
 data e.g. out of the output from some tool that provides you structured JSON
 or YAML text.

The [official repository](https://github.com/polettix/teepee) is on
[GitHub](https://github.com/).

## Installation

More on the [code](code/) page!

{% highlight bash %}
curl -LO https://github.com/polettix/teepee/raw/master/bundle/teepee
#   wget https://github.com/polettix/teepee/raw/master/bundle/teepee
chmod +x teepee
sudo mv teepee /usr/local/bin
{% endhighlight %}

Last step might be unwanted or not possible... just make sure you can
call `teepee` in some easy way!

## So What Can I Do?

More on the [cheatsheet](cheatsheet/) page!

{% highlight bash %}
# something about me
metacpan='http://api.metacpan.org/v0'
curl "$metacpan/author/POLETTIX" \
  | teepee -nT "Hi! I'm [% name %] <[% email.0 %]>."
# Hi! I'm Flavio Poletti <polet...pan.org>.

# for extracting multiple data, let's cache in a variable
me=$(curl "$metacpan/author/POLETTIX")
teepee -I "$me" -nT 'See my big face at [% gravatar_url %]?s=200'
# See my big face at http://www.gravatar.com/av...b57.png?s=200

# my favourite band
mbrz='http://musicbrainz.org/ws/2'
pjq=$(curl "$mbrz/artist?fmt=json&limit=1&query=Pearl%20Jam")
name=$(teepee -I "$pjq" -v artists.0.name)
country=$(teepee -I "$pjq" -v artists.0.country)
echo "$name rock from the $country"'!'
# Pearl Jam rock from the US!

# let's just isolate data about Pearl Jam from the query response
pj=$(teepee -I "$pjq" -F'YAML(V "artists.0")')
year=$(teepee -I "$pj" -v "'life-span'.begin")
city=$(teepee -I "$pj" -v "'begin-area'.name")
echo "they started from $city in $year"
# they started from Seattle in 1990

# we can also pretty-print, especially handy with compact JSON
ap='http://www.astro-phys.com/api/de406'
curl "$ap/coefficients?date=1972-11-9&bodies=mars"
# {"date": 2441630.5, "type": "chebyshev", "results": {"mars": ...
curl "$ap/coefficients?date=1972-11-9&bodies=mars" \
    | teepee -FYAML
# ---
# date: 2441630.5
# results:
#   mars:
#     coefficients:
#       -
#         - -221246363.667206
#         - 26761105.8067001
#         ...
#     end: 2441680.5
#     start: 2441616.5
# type: chebyshev
# unit: km

# or do the pretty-printing of a sub-section only
teepee -I "$pj" -F'YAML(V "aliases")'
# ---
# -
#   begin-date: ~
#   end-date: ~
#   locale: ~
#   name: 'Mookie Blaylock'
#   primary: ~
#   sort-name: 'Mookie Blaylock' type: ~

{% endhighlight %}

## Latest posts

<ul class="post-list">
{% for post in site.posts limit:10 %} <li><article><a href="{% if post.link %}{{ post.link }}{% else %}{{ site.url }}{{ site.baseurl }}{{ post.url }}{% endif %}">{{ post.title }} <span class="entry-date"><time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date: "%B %d, %Y" }}</time></span>{% if post.excerpt %} <span class="excerpt">{{ post.excerpt }}</span>{% endif %}</a></article></li> {% endfor %} </ul>
