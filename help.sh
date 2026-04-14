sudo certbot certonly --standalone \
  -d elevenstore.com \
  -d www.elevenstore.com \
  -d sellers.elevenstore.com \
  -d admin.elevenstore.com \
  --email support@elevenstore.com \
  --agree-tos \
  --non-interactive