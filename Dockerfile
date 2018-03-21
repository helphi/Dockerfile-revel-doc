FROM helphi/revel-doc:base

COPY revel.github.io-0.19.0 /revel.github.io

CMD ["jekyll", "serve", "-d", "/revel.github.io"]