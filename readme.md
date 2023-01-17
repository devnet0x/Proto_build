# Proto Build #

A bash shell script for basic interaction with Starknet [Protostar](https://github.com/software-mansion/protostar) to compile, declare and deploy contracts with just one call.
(only tested in ubuntu).
Any comments/corrections please reach me at my twitter account: [@devnet0x](https://twitter.com/devnet0x/)

## Usage ##


```
proto_build.sh <environment> <key_file> <json_compiled_file> [constructor parameters]
```
Where:

environment            : devnet or testnet

key_file               : File with public key in first line and private key in second line.

json_compiled_file     : File wich will contains json compiled file (as indicated in protostar.toml).

constructor parameters : Constructor parameters as felt.

## Example ##

In devnet:

```
$ ./proto_build.sh devnet acct1.key ./build/main.json 6704630963060302320922299142362055444976875123115280455327378123839557441680
Compiling...
21:28:07 [INFO] Execution time: 5.76 s
Declaring...
21:28:18 [INFO] Execution time: 9.83 s
Tx.Hash: 0x7beca724ed8a65cc14c6402182351288e7ab321555ef6755b32e94e857d0e6ef
"ACCEPTED_ON_L2"     
Deploying...
21:28:25 [INFO] Execution time: 2.85 s
Tx.Hash: 0x5A6632E4BBAA77B35C31FB5045BF12F8325406FFAD38782CEA17975192389F6
"ACCEPTED_ON_L2"     
Contract Address: 0x940a9e33fdbb061b79886b42222c6aa92a0ff24ed9cd384ee769e3bb41538e51
```

In testnet:

```
$ ./proto_build.sh testnet acct2.key ./build/main.json 6704630963060302320922299142362055444976875123115280455327378123839557441680
Compiling...
21:47:30 [INFO] Execution time: 4.99 s
Declaring...
21:47:40 [INFO] Execution time: 10.09 s
Tx.Hash: 0x06c861d71fc2967667525fa91fc1de420b6fb03527c27af864773f47e8899542
"ACCEPTED_ON_L2"     
Deploying...
21:49:16 [INFO] Execution time: 4.06 s
Tx.Hash: 0xBF5E24BCDB1B01B70CD5A028F955D1D96A066A94AA5EAD03D3C67F356DE1FE8
"ACCEPTED_ON_L2"     
Contract Address: 0xdd12bcf6a2b03a9824827de07cfec44a187030aae90937e98103499f15950be0
```

Key file example (first line public key and second line with private key):

```
$ more acct1.key 
0x74cdd372f75a571a7000d496e324876bbc8531f2d9a82bf154d1e04a50218ee
0x82c07cde3f50682c2094cac329f6fbed
```
