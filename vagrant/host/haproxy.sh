sudo apt update >/dev/null 2>/dev/null
sudo apt install haproxy >/dev/null 2>/dev/null

sudo cp haproxy.cfg /etc/haproxy/haproxy.cfg

sudo systemctl restart haproxy
