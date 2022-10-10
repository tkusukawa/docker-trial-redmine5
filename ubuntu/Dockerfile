FROM ubuntu:20.04

####################################################### SSHD
RUN apt update -y && apt install -y openssh-server

RUN mkdir /var/run/sshd
RUN echo 'root:password' | chpasswd
RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
 
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
 
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile


############################################### .bashrc
RUN echo >> /root/.bashrc
RUN echo bind "'\"\\C-n\": history-search-forward'" >> /root/.bashrc
RUN echo bind "'\"\\C-p\": history-search-backward'" >> /root/.bashrc
RUN echo 'PS1="\[\e[0;33m\]\D{%F %T}\n\[\e[1;32m\][\u@\h \W]# \[\e[0;37m\]"' >> /root/.bashrc

################################## 開発環境
RUN apt update -y && apt install -y \
  build-essential \
  zlib1g-dev \
  libssl-dev \
  libreadline-dev \
  libyaml-dev \
  libcurl4-openssl-dev \
  libffi-dev \
  apache2 \
  apache2-dev \
  imagemagick \
  fonts-takao-pgothic \
  sudo \
  git \
  subversion \
  iputils-ping \
  net-tools \
  iproute2


################################# 環境
RUN mkdir /root/.emacs.d
RUN git clone https://github.com/tkusukawa/.emacs.d.git /root/.emacs.d
RUN ln -s /root/.eamcs.d/.emacs /root/.emacs
RUN apt install -y wget curl tzdata locales emacs
RUN locale-gen ja_JP.UTF-8
ENV TZ Asia/Tokyo
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:ja


############################### RUBY (RBENV)
RUN git clone https://github.com/sstephenson/rbenv.git /usr/local/rbenv
RUN git clone https://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build
RUN echo '\n\
 export RBENV_ROOT="/usr/local/rbenv"\n\
 export PATH="${RBENV_ROOT}/bin:${PATH}"\n\
 eval "$(rbenv init -)"\n\
 ' >> /etc/profile

RUN . /etc/profile &&\
 cd ~ &&\
 rbenv install -v 3.1.2 &&\
 rbenv rehash &&\
 rbenv global 3.1.2


############################# MySQL
RUN apt update -y && apt install -y mysql-server mysql-client libmysqlclient-dev
RUN usermod -d /var/lib/mysql mysql
RUN service mysql start


########################### Passenger
RUN /usr/local/rbenv/shims/gem install passenger -N
RUN /usr/local/rbenv/shims/passenger-install-apache2-module --auto --languages ruby
RUN /usr/local/rbenv/shims/passenger-install-apache2-module --snippet > /tmp/passenger.snippet


############################# Redmine
RUN mkdir -p /opt/redmine
RUN svn co https://svn.redmine.org/redmine/branches/5.0-stable /opt/redmine

COPY database.yml /opt/redmine/config/
WORKDIR /opt/redmine
RUN /usr/local/rbenv/shims/bundle install --without development test
RUN chown -R www-data:www-data /opt/redmine

COPY redmine.conf* /tmp/
RUN cat /tmp/redmine.conf1 /tmp/passenger.snippet /tmp/redmine.conf3 > /etc/apache2/conf-available/redmine.conf
RUN a2enconf redmine
COPY 000-default.conf /etc/apache2/sites-enabled/
RUN apache2ctl configtest 

###################### chupa-text-http-server
RUN git clone https://github.com/ranguba/chupa-text-http-server.git /opt/chupa-text
WORKDIR /opt/chupa-text
RUN cp Gemfile.local.example Gemfile.local
RUN apt install -y libglib2.0-dev libgirepository1.0-dev libpoppler-glib-dev libgdk-pixbuf2.0-dev
RUN /usr/local/rbenv/shims/bundle install
RUN /usr/local/rbenv/shims/bundle exec rake secret > /tmp/chupa-text.secret
RUN mv config/secrets.yml config/secrets.yml.org
RUN echo 'production:' > config/secrets.yml
RUN echo -n '  secret_key_base: ' | cat - /tmp/chupa-text.secret >> config/secrets.yml
RUN echo >> config/secrets.yml
RUN chown -R www-data:www-data /opt/chupa-text

COPY chupa-text.conf* /tmp/
RUN cat /tmp/chupa-text.conf1 /tmp/passenger.snippet /tmp/chupa-text.conf3 > /etc/apache2/conf-available/chupa-text.conf
RUN a2enconf chupa-text
RUN apache2ctl configtest 


EXPOSE 22 80 3000 3306
COPY entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]
