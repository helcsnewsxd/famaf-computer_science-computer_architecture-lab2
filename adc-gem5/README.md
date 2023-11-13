# AdC Lab 2

## Estructura de archivos

- `run_simulation.sh`: Archivo para correr la simulación, en el se debe elegir el benchmark a correr y la configuración del procesador a utilizar.
- `benchmarks`: Carpeta donde se encuentran los templates de los tres ejercicios a resolver.
- `scripts`: Carpeta que incluye todos los scripts de ejecución y configuración de la simulación de ejecución del procesador.
  + `cpu_config.toml` - archivo que tiene configuraciones generales del micro, aplican a cualquier configuración de procesador que ejecuten.
  + `in_order.py` - template del procesador in order.
  + `out_of_order.py` - template del procesador out of order.
  + `se.py` - script principal que ejecuta las simulaciones en base a las configuraciones especificadas.
  + `devices.py` - script que efectivamente crea el CPU que gem5 va a correr.
  + `stat-collect.py` - script que recolecta y recalcula algunos resultados de la simulación.

## Cómo crear una configuración

Comenzar creando un nuevo archivo `.py` en el mismo lugar donde está `se.py`, si la configuración es por ejemplo, para un CPU in-order.

```sh
cp in_order.py nuevo_cpu.py
```

Al final del archivo hay 2 variables `cpu_name` y `cpu_spec`, como el nombre implica, pueden cambiar el nombre del CPU con `cpu_name`, el nombre por defecto es el mismo que el del archivo (sin .py) por lo que no es necesario cambiarlo.
Salvo para deshabilitar la caché L2, poniendo None en su lugar, no tocar `cpu_spec`.

Luego de configurar el nuevo CPU, importarlo en `se.py`, y después agregar su nuevo CPU en el diccionario global `cpu_types`, el cambio se debería ver algo como esto.

```py
import in_order
import out_of_order
...
import nuevo_cpu

...

cpu_types = {
    in_order.cpu_name: in_order.cpu_spec,
    out_of_order.cpu_name: out_of_order.cpu_spec,
    ...
    nuevo_cpu.cpu_name: nuevo_cpu.cpu_spec,
}

...
```

Con eso se puede elegir el nuevo CPU para correr la simulación.


## Como correr la simulación

Ejecutar el script `./run_simulation.sh` definiendo las variables de entorno BENCHMARK con 'daxpy' 'simFisica' o 'bubbleSort' y PROCESSOR con el nombre del procesador que quieran usar.

Ejemplo:

```sh
BENCHMARK=simFisica PROCESSOR=out_of_order ./run_simulation.sh
```
