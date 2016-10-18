
To build and upload an application catalog

cd nginx
zip -r com.example.nginx.zip *
source ~/murano/keystonerc
murano package-import com.example.nginx.zip
