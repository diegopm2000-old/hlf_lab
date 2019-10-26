# Ejecucion de funciones del contrato

Para el contrato que hemos creado, que no es más que un acumulador, tenemos tres funciones:

- create: inicializan el acumulador a 0
- increment: incrementa en el valor pasado como parámetro el acumulador
- getValue: obtiene el valor actual del acumulador

### 1.Crear el acumulador e inicializarlo a 0

```shell
$ docker exec cli peer chaincode invoke \
--tls \
-o orderer0.ust.com:7050 \
--cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/ust.com/orderers/orderer0.ust.com/msp/tlscacerts/tlsca.ust.com-cert.pem \
-C channel0 -n mycounter -c '{"Args":["create"]}'
```

### 2. Obtener el valor del acumulador

```shell
$ docker exec cli peer chaincode invoke \
--tls \
-o orderer0.ust.com:7050 \
--cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/ust.com/orderers/orderer0.ust.com/msp/tlscacerts/tlsca.ust.com-cert.pem \
-C channel0 -n mycounter -c '{"Args":["getValue"]}'
```

### 3. Incrementar the accumulator

```shell
$ docker exec cli peer chaincode invoke \
--tls \
-o orderer0.ust.com:7050 \
--cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/ust.com/orderers/orderer0.ust.com/msp/tlscacerts/tlsca.ust.com-cert.pem \
-C channel0 -n mycounter -c '{"Args":["increment", "5"]}'
```
