export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
sudo locale-gen --purge en_US.UTF-8
echo -e 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"\n' > sudo /etc/default/locale
