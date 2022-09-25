{
  inputs = {
     nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
     website.url = "github:truroshan/django-nextjs-nix";

  };

  outputs = { nixpkgs,website, ... }: rec {
        
        colmena = {
          meta = {
            nixpkgs = import nixpkgs {
              system = "x86_64-linux";
            };
          };
          
          do-droplet = {
            deployment = {
              targetHost = "192.168.0.1";  # server ip-address or domain name
              targetPort = 22;
              buildOnTarget = true;
              targetUser = "root";
              tags = [ "web" ];
            };

            networking.firewall.allowedTCPPorts = [ 80 443 22 ];

            services.openssh.enable = true;

            virtualisation.oci-containers.containers = {
              
              "nextapp" = {
                            image = "nextapp:stable";
                            imageFile = website.packages.x86_64-linux.nextAppImage;
                            ports = [ "3000:3000" ];
                };

              "djangoapp" = {
                            image = "djangoapp:stable";
                            imageFile = website.packages.x86_64-linux.djangoAppImage;
                            ports = [ "8080:8080" ];
                };
            };

            # Connect Domain and enable Nginx
            services.nginx.enable = false;

            security.acme.acceptTerms = true;
            security.acme.email = "email@gmail.com";


            services.nginx.virtualHosts = {
              
              "example.com" = {
                default = true;
                forceSSL = true;
                enableACME = true;
                locations."/".return = "200 \"Hello from Nixie!\"";
              };

              "next.example.com" = {
                    forceSSL = true;
                    enableACME = true;
                    locations."/" = {
                      proxyPass = "http://localhost:3000";
                    };
                  };

              "django.example.com" = {
                forceSSL = true;
                enableACME = true;
                locations."/" = {
                  proxyPass = "http://localhost:8080";
                };
              };

            };


            system.stateVersion = "21.11";
            boot.isContainer = true;
            time.timeZone = "Asia/Kolkata";
            };
          
          };
    };
}
