# Creación de una red mínima con Hyperledger-Fabric

La idea de este mini tutorial es crear una red mínima de hyperledger, a modo de test, partiendo de una hoja en blanco. 

Crearemos la red, desplegaremos un smart contract (chaincode) de Hyperledger en NodeJS y ejecutaremos algunas de sus funciones.

## 0. Obtención de los binarios de Hyperledger-Fabric.

Los binarios de Hyperledger-Fabric ya se encuentran en la carpeta de binarios de este tutorial, pero se pueden obtener siguiendo los siguientes pasos que se muestran a continuación a modo de información añadida al tutorial.

En caso de no estar interesado de saber como se obtienen, pasar al punto 1.

### 0.1 Descargar el Fabric-Samples de la última versión

Descargamos el repositorio, en la versión release-1.4

https://github.com/hyperledger/fabric-samples

Nos bajaría un fichero de nombre:

```
fabric-samples-release-1.4.zip
```

Descomprimimos el fichero en nuestra carpeta de trabajo, y quedará con el nombre:

```
fabric-samples-release-1.4
```

Necesitamos renombrarlo a fabric-Samples

```shell
$ mv fabric-samples-release-1.4 fabric-samples
```

### 0.2. Ejecutamos el script de bootstrap

Nos movemos a la carpeta de fabric-samples

```shell
$ cd fabric-samples
```

Y ejecutamos el script de bootstrap:

```shell
./scripts/bootstrap.sh

Installing Hyperledger Fabric binaries

===> Downloading version 1.4.0 platform specific fabric binaries
===> Downloading:  https://nexus.hyperledger.org/content/repositories/releases/org/hyperledger/fabric/hyperledger-fabric/linux-amd64-1.4.0/hyperledger-fabric-linux-amd64-1.4.0.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 50.9M  100 50.9M    0     0  11.2M      0  0:00:04  0:00:04 --:--:-- 11.2M

...
...
===> List out hyperledger docker images
hyperledger/fabric-tools                                                                             1.4.0               0a44f4261a55        6 weeks ago         1.56GB
hyperledger/fabric-tools                                                                             latest              0a44f4261a55        6 weeks ago         1.56GB
hyperledger/fabric-ccenv                                                                             1.4.0               5b31d55f5f3a        6 weeks ago         1.43GB
hyperledger/fabric-ccenv                                                                             latest              5b31d55f5f3a        6 weeks ago         1.43GB
hyperledger/fabric-orderer                                                                           1.4.0               54f372205580        6 weeks ago         150MB
hyperledger/fabric-orderer                                                                           latest              54f372205580        6 weeks ago         150MB
hyperledger/fabric-peer                                                                              1.4.0               304fac59b501        6 weeks ago         157MB
hyperledger/fabric-peer                                                                              latest              304fac59b501        6 weeks ago         157MB
hyperledger/fabric-ca                                                                                1.4.0               1a804ab74f58        6 weeks ago         244MB
hyperledger/fabric-ca                                                                                latest              1a804ab74f58        6 weeks ago         244MB
hyperledger/fabric-zookeeper                                                                         0.4.14              d36da0db87a4        4 months ago        1.43GB
hyperledger/fabric-zookeeper                                                                         latest              d36da0db87a4        4 months ago        1.43GB
hyperledger/fabric-kafka                                                                             0.4.14              a3b095201c66        4 months ago        1.44GB
hyperledger/fabric-kafka                                                                             latest              a3b095201c66        4 months ago        1.44GB
hyperledger/fabric-couchdb                                                                           0.4.14              f14f97292b4c        4 months ago        1.5GB
hyperledger/fabric-couchdb                                                                           latest              f14f97292b4c        4 months ago        1.5GB
hyperledger/fabric-baseos                                                                            amd64-0.4.14        75f5fb1a0e0c        4 months ago        124MB

```

Con esto ya tendríamos los binarios preparados para empezar a construir la red, dentro de la carpeta bin.

Esta misma carpeta bin tal cual es la que viene ya las fuentes de este tutorial.

## 1. Creación de un proyecto minimalista de HyperLedger-Fabric

Para nuestro proyecto minimalista, vamos a definir primero la red, que va a ser lo más sencilla posible

### 1.1 Creación de la estructura mínima de la red que vamos a crear

Hemos definido una estructura mínima en el fichero crypto-config.yaml, que consiste en una única organización, con un orderer y un peer:

```yaml
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

# ---------------------------------------------------------------------------
# "OrdererOrgs" - Definition of organizations managing orderer nodes
# ---------------------------------------------------------------------------
OrdererOrgs:
  - Name: Orderer
    Domain: ust.com
    Specs:
      - Hostname: orderer
    Template:
      Count: 1
PeerOrgs:
  # ---------------------------------------------------------------------------
  # Org1
  # ---------------------------------------------------------------------------
  - Name: Org1
    Domain: org1.ust.com
    EnableNodeOUs: true
    Template:
      Count: 1
    Users:
      Count: 1
```

También hemos creado el fichero __configtx.yaml__ con la configuración de la red necesaria.

Se recomienda ver el fichero en detalle para más información.

### 1.2 Generamos el material criptográfico necesario

Ejecutamos el script __generate_config.sh__, que necesita los dos ficheros anteriormente descritos.

```shell
./generate_config.sh
```

Durante esta ejecución, se hace lo siguiente:

- Limpia los directorios config y crypto-config en caso de que existieran por haber lanzado ya el script anteriormente
- Genera el material criptográfico
- Genera el bloque Genesis inicial
- Genera la configuración de los canales (sólo tenemos un canal)
- Actualiza los Anchor peers
- Inserta las claves .pem en el docker-compose.yml. Para ello se parte de un fichero docker-compose.yml.BAK como base.

### 1.3 Arranque de los contenedores

Vamos ahora a arrancar los contenedores.

```shell
$ docker-compose up -d
```

En nuestra red minimalista, los contenedores que arrancamos son los siguientes:

__ca.org1.ust.com__: Hyperledger Fabric CA

Hyperledger Fabric CA Proporciona características tales como:

- Registro de identidades, o se conecta a LDAP como el registro de usuarios
- Emisión de Certificados de Inscripción (ECerts)
- Renovación y revocación de certificados.

__orderer0.ust.com__: Hyperledger Orderer

Hyperledger Orderer proporciona un canal de comunicación compartido a clientes y peers, ofreciendo un servicio de difusión para mensajes que contienen transacciones. Los clientes se conectan al canal y pueden transmitir mensajes en el canal que luego se entregan a todos los pares. El canal admite la entrega atómica de todos los mensajes, es decir, la comunicación de mensajes con la entrega total del pedido y la confiabilidad (específica de la implementación). En otras palabras, el canal envía los mismos mensajes a todos los interlocutores conectados y los envía a todos los interlocutores en el mismo orden lógico.

__peer0.org1.ust.com__: Hyperledger Peer 0

Es nuestro único nodo peer de la red. Contiene una copia del Ledger del canal, y está asociado a la base de datos couchDB. 

__couchdb0__: Base de datos del Peer 0

Aquí el peer guarda la información del Ledger del canal.

__cli__: Es un cliente que usamos para interactuar con el peer 0. 

Usando este cliente, podemos interactuar con la red, desplegar contratos y ejecutar funciones sobre ellos.

__kafka0__, __kafka1__, __kafka2__, __zookeeper0__, __zookeeper1__, __zookeeper2__: Cluster de Kafka y sus zookeeper asociados.

El __consenso__ en blockchain involucra nodos que acuerdan el mismo orden de transacciones. Los nodos de pedido se envían a las transacciones de Kafka y se reciben de las transacciones de Kafka en el mismo orden, ya que Kafka funciona como una abstracción de una cola compartida.

Todos los __orderers__ crean bloques cuando leen suficientes mensajes o suficientes datos de kafka. Además, si se envió una transacción pero no se creó un bloque, y ha transcurrido el tiempo suficiente (tiempo de espera), el nodo del ordenante enviará un mensaje especial a Kafka que indicará a todos los nodos orderer que corte un bloque. Esto asegura que todos los ordenadores cortan bloques en función del tiempo de espera, pero también que cortan los mismos bloques.

Cada peer líder se conecta a un __orderer__ aleatorio y luego envía una solicitud, indicando desde qué índice de bloque quiere recibir los bloques. Luego, el __orderer__ lee los bloques de su sistema de archivos y los envía al interlocutor. Cuando el peer recibe los bloques, también los envía a otros peers a través del componente de gossip que hay dentro del peer, lo que garantiza que los peers permanezcan sincronizados.

### 1.4 Actualización de la red

Ahora actualizamos la red, ejecutando:

```shell
$ ./update_channels.sh
```

En este script, se hace lo siguiente:

- se crea el canal
- se añade el peer al canal
- se actualiza el anchor peer

### 1.5 Instalación del chaincode

Para instalar el chaincode, tenemos que ejecutar:

```shell
$ ./chaincodeNodeJS.sh
```

Con esto instalamos e instanciamos el chaincode del tutorial. 

### 1.6 Ejecución de métodos públicos del chaincode

Continuar en el fichero chaincodeNodeJS_ops.md para más detalle
