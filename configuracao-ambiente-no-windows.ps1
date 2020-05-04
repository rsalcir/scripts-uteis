# script utilitario para configurar o ambiente de desenvolvimento

write-Host "Inciando instalação dos apps para trabalho..."

#instalando chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install git
choco install winrar
choco install intellijidea-ultimate
choco install docker-desktop
choco install slack

write-Host "Fim da instalação dos apps para trabalho."