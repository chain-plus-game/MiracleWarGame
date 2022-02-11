// Right click on the script name and hit "Run" to execute

(async () => {
    try {
        console.log('Running deployWithEthers script...')
        const provider = new ethers.providers.Web3Provider(web3Provider);
        const signer = provider.getSigner()
        const address = await signer.getAddress();

        console.log(`cur address is ${address}`);

        async function getAbi(name){
            // Note that the script needs the ABI which is generated from the compilation artifact.
            // Make sure contract is compiled and artifacts are generated
            const artifactsPath = `browser/contracts/artifacts/${name}.json` // Change this for different path

            const metadata = JSON.parse(await remix.call('fileManager', 'getFile', artifactsPath))
            return metadata;
        }
        async function deployContract(name,args){
            console.log(`begin to deploy ${name}.sol`);

            const metadata = await getAbi(name);
            let factory = new ethers.ContractFactory(metadata.abi, metadata.data.bytecode.object, signer);
            console.log('deployer args is:',constructorArgs)

            let cardContract = await factory.deploy(...constructorArgs);
            const deployAddress = cardContract.address;
            // The contract is NOT deployed yet; we must wait until it is mined
            await cardContract.deployed()
            console.log(`Deployment ${name} successful.`)
            return deployAddress;
        }
        async function getContract(name,contractAddress){
            const metadata = await getAbi(name);
            const contract = new ethers.Contract(contractAddress, metadata.abi, provider);
            return contract.connect(signer);
        }
        let contractName = 'MiracleCard' // Change this for other contract
        let constructorArgs = [address, 100]    // Put constructor args (if any) here for your contract
        const cardContractAddress = await deployContract(contractName, constructorArgs);
        console.log(`card contract address is: ${cardContractAddress}`);
        const cardContract = await getContract(contractName,cardContractAddress);

        console.log("all contract deploy success");

    } catch (e) {
        console.log(e.message)
    }
})()