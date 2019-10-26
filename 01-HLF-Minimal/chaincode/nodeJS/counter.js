// counter.js

/* eslint-disable class-methods-use-this */
/* eslint-disable no-console */

const shim = require('fabric-shim');

const moduleName = '[ChainCode Accumulator';

const Chaincode = class {
  async Init() {
    console.info(`--> ${moduleName}::Init -> Instantiated OK!`);
    return shim.success();
  }

  async Invoke(stub) {
    const ret = stub.getFunctionAndParameters();
    console.info(ret);

    const method = this[ret.fcn];
    console.log(ret.params);

    if (!method) {
      console.error(`--> ${moduleName}::Invoke (ERROR) --> no function of name:${ret.fcn} found`);
      throw new Error(`Unknown function ${ret.fcn}`);
    }

    try {
      const payload = await method(stub, ret.params);
      return shim.success(payload);
    } catch (err) {
      console.error(`--> ${moduleName}::Invoke (ERROR) --> ${err.message}`);
      return shim.error(err);
    }
  }

  async create(stub, args) {
    console.error(`--> ${moduleName}::create (IN) --> stub: ${stub}, args: ${JSON.stringify(args)}`);

    const newCounter = {
      docType: 'counter',
      value: 0,
    };

    await stub.putState('counter0', Buffer.from(JSON.stringify(newCounter)));

    console.error(`--> ${moduleName}::create (OUT) --> new accumulator created OK!`);
  }

  async getValue(stub, args) {
    console.error(`--> ${moduleName}::getValue (IN) --> stub: ${stub}, args: ${JSON.stringify(args)}`);

    const myCounter = await stub.getState('counter0');

    console.error(`--> ${moduleName}::increment (OUT) --> ${JSON.stringify(myCounter)}`);
    return myCounter;
  }

  async increment(stub, args) {
    console.error(`--> ${moduleName}::increment (IN) --> stub: ${stub}, args: ${JSON.stringify(args)}`);

    // Check Args
    if (args.length !== 1) {
      throw new Error('Invalid number of arguments');
    }

    const myCounterRaw = await stub.getState('counter0');
    const myCounter = JSON.parse(myCounterRaw);

    // Apply the increment
    myCounter.value += parseInt(args[0], 10);

    await stub.putState('counter0', Buffer.from(JSON.stringify(myCounter)));

    console.error(`--> ${moduleName}::increment (OUT) --> accumulator set to: ${JSON.stringify(myCounter)}`);
  }
};

shim.start(new Chaincode());
