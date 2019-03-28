FROM tiangolo/uwsgi-nginx:python3.6

RUN pip install psycopg2-binary

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

ENTRYPOINT ["/usr/bin/supervisord"]

# CMD ["/usr/bin/supervisord"]

COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY manage.py /app/manage.py
COPY wasmerspeed /app/wasmerspeed
COPY project /app/project

RUN mkdir /app/media/

# Collect static files
RUN python manage.py collectstatic --noinput
