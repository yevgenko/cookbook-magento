require 'fileutils'

class Chef
  class Recipe
    class Magento
      def self.create_ssl_cert(cert_path, domain, file_name)
        pem_file = File.join(cert_path, file_name)

        unless File.exist?(pem_file)
          f = FileUtils
          f.mkdir_p cert_path

          # One-liner to generate a SSL cert
          system "openssl req -x509 -nodes -days 365 -subj '/CN=#{domain}/O=O"\
                 "ps/C=ZZ/ST=State/L=City' -newkey rsa:4096 -keyout "\
                 "#{pem_file} -out #{pem_file} 2>/dev/null"
        end
      end
    end
  end
end
