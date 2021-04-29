FroggerBoot

Introducción
Frogger es un juego de arcade desarrollado por Konami y originalmente publi-cado por Sega.  
El objetivo del juego es guiar a las ranas a sus hogares, una poruna, cruzando carreteras
y r ́ıos con muchos peligros.  El problema planteado enla asignaci ́on es programar en 
ensamblador el booteo desde una unidad USB,donde una vez que bootee, se cargue unicamente
un programa llamado Frogger.En  este  caso,  el  booteo  con  USB  se  simulara  con  una
máquina  virtual  y  un archivo ISO.

Ambiente de trabajo

-Sistema Operativo Ubuntu 18.04 para compilacion del .asm

- QEMU:Sistema emulador de software.

- Visual Studio Code:Editor de texto.

- Bilioteca UEFI

- Oracle Virtual Box: Emulador para verificacion del resultado final.

Instrucciones para ejecutar el programa.

Se debe abrir una terminal donde se tienen los archivos, seguidamente se debeejecutar el comando make all, lo cual generar ́a una serie de archivos, entre esosun .iso.Una vez que se dispone del .iso se debe abrir una nueva m ́aquina virtual, vamosa ”Settings” y se le debe habilitar en la secci ́on de ”System”, la opci ́on ”EnableEFI”, despu ́es se debe seleccionar el .iso en la secci ́on de ”Storage”.Esto har ́a que la m ́aquina arranque en modo EFI con el juego Frogger.
