echo -e "\e[32m  ____    ____ _____  _    _    _______ __    __ _______ _____  _       _______  _______  \e[0m"
echo -e "\e[32m | |\ \  / /| | ____|| |  | |  |_______|\ \ _/ /|   O  || ____|| |____ |   __  ||_______| \e[0m"
echo -e "\e[32m | | \ \/ / | |  _   | |__| |     | |    \    / | |____||  _   |   0  ||  |__| |   | |    \e[0m"
echo -e "\e[32m |_|  \__/  |_|_____||______|     |_|  |_____/  |_|     |_____||______||_______|   |_|    \e[0m"
echo -e "\e[32m                                                                                          \e[0m"
echo -e "\e[32m         ____    ____   _  _     _  ______  ____    _   __//__  ______  _  ______         \e[0m"
echo -e "\e[32m        | |\ \  / /| | | || |   | ||  __  || |\ \  | | | ____ || |__| || ||  __  |        \e[0m"
echo -e "\e[32m        | | \ \/ / | | | || |__ | || |__| || | \  \| | | |__| || |\  \ | || |__| |        \e[0m"
echo -e "\e[32m        |_|  \__/  |_| |_||____||_||______||_|  \____| |_|  |_||_|  \_||_||______|        \e[0m" 
echo -e "\e[32m                                                                                          \e[0m"                                                                                                                                            
echo -e "\e[32m                  Auto Instalador Docker/Portainer Meu Typebot Milionario                 \e[0m"
echo -e "\e[32m                                                                                          \e[0m"
echo -e "\e[32m                         https://www.youtube.com/@Imperadordesonhos                       \e[0m"
echo -e "\e[32m\e[0m"
echo -e "\e[32m\e[0m"
# Função para mostrar um banner colorido
function show_banner() {
echo -e "\e[32m==============================================================================\e[0m"
echo -e "\e[32m=                                                                            =\e[0m"
echo -e "\e[32m=                 \e[33mPreencha as informações abaixo com atenção\e[32m                 =\e[0m"
echo -e "\e[32m=                                                                            =\e[0m"
echo -e "\e[32m==============================================================================\e[0m"
}
# Função para mostrar uma mensagem de etapa
function show_step() {
  echo -e "\e[32mPasso \e[33m$1/5\e[0m"
}
# Mostrar banner inicial
clear
show_banner
echo ""
# Solicitar informações do usuário
show_step 1
read -p "📧 Endereço de e-mail: " email
echo ""
show_step 2
read -p "🌐 Dominio do Traefik (ex: traefik.seudominio.com): " traefik
echo ""
show_step 3
read -s -p "🔑 Senha do Traefik: " senha
echo ""
echo ""
show_step 4
read -p "🌐 Dominio do Portainer (ex: portainer.seudominio.com): " portainer
echo ""
show_step 5
read -p "🌐 Dominio do Edge (ex: edge.seudominio.com): " edge
echo ""
# Verificação de dados
clear
echo ""
echo "📧 Seu E-mail está certo? $email"
echo "🌐 Seu domínio do Traefik está certo? $traefik"
echo "🔑 Senha do Traefik: ********"
echo "🌐 Seu domínio do Portainer está certo? $portainer"
echo "🌐 Seu domínio do Edge está certo? $edge"
echo ""
read -p "Se as informações estiverem corretas aperte 'y', se alguma informação estiver errada aperte 'n'? (y/n): " confirma1
if [ "$confirma1" == "y" ]; then
  clear
  #########################################################
  # INSTALANDO DEPENDENCIAS
  #########################################################
  sudo apt update -y && sudo apt upgrade -y
  sudo apt install -y curl
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  mkdir -p ~/Portainer && cd ~/Portainer
  echo -e "\e[32mAtualizado/Instalado com Sucesso\e[0m"
  sleep 3
  clear
  #########################################################
  # CRIANDO DOCKER-COMPOSE.YML
  #########################################################
  cat > docker-compose.yml <<EOL
services:
  traefik:
    container_name: traefik
    image: "traefik:latest"
    restart: always
    command:
      - --entrypoints.web.address=:80
      - --entrypoints.websecure.address=:443
      - --api.insecure=true
      - --api.dashboard=true
      - --providers.docker
      - --log.level=ERROR
      - --certificatesresolvers.leresolver.acme.httpchallenge=true
      - --certificatesresolvers.leresolver.acme.email=$email
      - --certificatesresolvers.leresolver.acme.storage=./acme.json
      - --certificatesresolvers.leresolver.acme.httpchallenge.entrypoint=web
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock:ro"
      - "./acme.json:/acme.json"
    labels:
      - "traefik.http.routers.http-catchall.rule=hostregexp(\`{host:.+}\`)"
      - "traefik.http.routers.http-catchall.entrypoints=web"
      - "traefik.http.routers.http-catchall.middlewares=redirect-to-https"
      - "traefik.http.middlewares.redirect-to-https.redirectscheme.scheme=https"
      - "traefik.http.routers.traefik-dashboard.rule=Host(\`$traefik\`)"
      - "traefik.http.routers.traefik-dashboard.entrypoints=websecure"
      - "traefik.http.routers.traefik-dashboard.service=api@internal"
      - "traefik.http.routers.traefik-dashboard.tls.certresolver=leresolver"
      - "traefik.http.middlewares.traefik-auth.basicauth.users=$senha"
      - "traefik.http.routers.traefik-dashboard.middlewares=traefik-auth"
  portainer:
    image: portainer/portainer-ce:latest
    command: -H unix:///var/run/docker.sock
    restart: always
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.frontend.rule=Host(\`$portainer\`)"
      - "traefik.http.routers.frontend.entrypoints=websecure"
      - "traefik.http.services.frontend.loadbalancer.server.port=9000"
      - "traefik.http.routers.frontend.service=frontend"
      - "traefik.http.routers.frontend.tls.certresolver=leresolver"
      - "traefik.http.routers.edge.rule=Host(\`$edge\`)"
      - "traefik.http.routers.edge.entrypoints=websecure"
      - "traefik.http.services.edge.loadbalancer.server.port=8000"
      - "traefik.http.routers.edge.service=edge"
      - "traefik.http.routers.edge.tls.certresolver=leresolver"
volumes:
  portainer_data:
EOL
  #########################################################
  # CERTIFICADOS LETSENCRYPT
  #########################################################
  echo -e "\e[32mInstalando certificado LetsEncrypt\e[0m"
  touch acme.json
  sudo chmod 600 acme.json
  #########################################################
  # INICIANDO CONTAINER
  #########################################################
  sudo docker compose up -d
echo -e "\e[32m\e[0m"
echo -e "\e[32m\e[0m"
echo -e "\e[32m\e[0m"
echo -e "\e[32m\e[0m"
echo -e "\e[32m _                             _              _        \e[0m"
echo -e "\e[32m| |                _          | |            | |       \e[0m"
echo -e "\e[32m| | ____    ___  _| |_  _____ | |  _____   __| |  ___  \e[0m"
echo -e "\e[32m| ||  _ \  /___)(_   _)(____ || | (____ | / _  | / _ \ \e[0m"
echo -e "\e[32m| || | | ||___ |  | |_ / ___ || | / ___ |( (_| || |_| |\e[0m"
echo -e "\e[32m|_||_| |_|(___/    \__)\_____| \_)\_____| \____| \___/ \e[0m"
echo -e "\e[32m                                                       \e[0m" 
echo -e "\e[32mAcesse o Portainer através do link: https://$portainer\e[0m"
echo -e "\e[32mAcesse o Traefik através do link: https://$traefik\e[0m"
echo -e "\e[32m\e[0m"
echo -e "\e[32mSugestões ou duvidas: meutypebotmilionario@gmail.com\e[0m"
else
  echo "Encerrando a instalação, por favor, inicie a instalação novamente."
  exit 0
fi
