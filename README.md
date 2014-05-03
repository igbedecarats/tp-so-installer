tp-so-installer
===============

This is a test repository to implement the installer for the installer of the "precios cuidados" project for Operative Systems at FIUBA: http://materias.fi.uba.ar/7508/Practica-2014/sotp2014_1C_temaD.pdf


Instrucciones de instalacion
----------------------------

1. Acceda a la terminal.
2. Copie el archivo tp-grupo01.tgz a la carpeta en la que quiere realizar la instalacion:
	$ cp [ruta_paquete]/tp-grupo01.tgz [ruta_instalacion]
3. Vaya a la carpeta de instalacion y extraiga el contenido del paquete de instalacion:
	$ cd [ruta_instalacion]
	$ tar -xvf tp-grupo01.tgz
4. Dele permisos al instalador instalarC.sh:
	$ cd tp-grupo01
	$ chmod u+rx instalarC.sh
5. Ejecute el instalador:
	$ ./instalarC.sh

En este punto el programa ya esta instalado y listo para usar.

Inicializacion
--------------

Una vez instalado, acceda a la carpeta en la que instalo los ejecutables de Consultar y ejecute el comando iniciarC.sh:
	$ . iniciarC.sh

Esto inicializara el entorno para poder utilizar los demas comandos, y dejara corriendo el daemon detectarC, de manera que puede ir copiando las encuestas en la carpeta de arribos seleccionada cuando instalo el programa.

Finalizacion
------------

Para detener el programa, ejecute en la terminal, desde el directorio lib de Consultar:
	$ ./StopD.sh
