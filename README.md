# podcast-dl

Downloads podcasts using RSS feeds. Uses `If-None-Match` and `If-Modified-Since` headers to avoid pulling the RSS feed repeatedly. Also resets some of the ID3 metadata that's likely to be wrong (only release date for now, but easily extended). Metadata modification depends on calling out to the `eyeD3` executable, which is unfortunate but not as bad as trying to write the ID3v2.4 tags myself.

Written in Ruby to see if it's any good. In the end, feels basically like Perl with a few sharp edges removed. Whether that's good or bad is left as an exercise to the reader.

Expects a configuration file located at `~/.config/podcast-dl.json` in the form:

```json
{
  "directory": "/mnt/Library/podcasts",
  "feeds": [
    {
      "name": "Stuff You Should Know",
      "url": "https://www.omnycontent.com/d/playlist/e73c998e-6e60-432f-8610-ae210140c5b1/a91018a4-ea4f-4130-bf55-ae270180c327/44710ecc-10bb-48d1-93c7-ae270180c33e/podcast.rss",
      "etag": "W/\"d2f80f588bf2fd38cb084e31e7a8e998526dd7d4\"",
      "lastModified": null
    },
    {
      "name": "Planet Money",
      "url": "https://feeds.npr.org/510289/podcast.xml",
      "etag": "\"a091ce7222fe7dbd64116996f8451b68:1739747411.358957\"",
      "lastModified": "Sun, 16 Feb 2025 23:10:11 GMT"
    }
  ]
}
```

Configuration file will be modified on every run, as the `ETag` and `Last-Modified` headers are updated form the feeds. The MP3 files will be downloaded into the directory marked in the configuration file, with one folder for each feed.
