contract OSCP {
    
    address[1000] stakeholders;
    uint[1000] stakeholderVotes;
    mapping(address=>uint) stakeholderMap;
    uint stakeholderIndex;
    
    mapping(uint=>string) ClassFiles;
    mapping(uint=>mapping(uint=>string)) OSmartContracts;
    mapping(uint=>mapping(uint=>uint)) OSmartContractState;
    mapping(uint=>mapping(uint=>uint)) OSmartContractVotes;
    uint OSmartContractIndex;
    uint[] OTxnIndex;
    
    uint requiredVotes;
    
    event txnVerified(uint contractIndex, uint txnIndex); 

    
    function OSCP(address[] _stakeholders, uint[] _votes, uint consensusPercentage){
        uint totalVotes;
        for (uint i=0;i<_stakeholders.length;++i) {
            ++stakeholderIndex;
            stakeholders[stakeholderIndex] = _stakeholders[i];
            stakeholderMap[_stakeholders[i]] = stakeholderIndex;
            stakeholderVotes[stakeholderIndex] = _votes[i];
            totalVotes += _votes[i];
        }
        requiredVotes = consensusPercentage * totalVotes / 100;
    }
    
    function createOJSC(string classIPFSHash, string stateIPFSHash) returns (uint) {
        if (stakeholderMap[msg.sender]>0) {
            ++OSmartContractIndex;
            ClassFiles[OSmartContractIndex] = classIPFSHash;
            OTxnIndex[OSmartContractIndex] = 1;
            OSmartContracts[OSmartContractIndex][1] = stateIPFSHash;
            OSmartContractState[OSmartContractIndex][1] = 1;
            OSmartContractVotes[OSmartContractIndex][1] = stakeholderVotes[stakeholderMap[msg.sender]];
            verifyCreationOfOSC(OSmartContractIndex);
            return OSmartContractIndex;
        }else{
            return 0;
        }
    }
    
    function verifyCreationOfOSC(uint contractIndex) {
        if (stakeholderMap[msg.sender]>0) {
            OSmartContractVotes[contractIndex][1] += stakeholderVotes[stakeholderMap[msg.sender]];
            if (OSmartContractVotes[contractIndex][1]>=requiredVotes){
                ++OSmartContractIndex;
                OTxnIndex[OSmartContractIndex] = 1;
                OSmartContractState[OSmartContractIndex][1] = 2;
                txnVerified(contractIndex, 1);
            }
        }
    }
    
    function createTxn(uint contractIndex, string stateIPFSHash) returns (uint) {
        if (stakeholderMap[msg.sender]>0 &&  OSmartContractState[contractIndex][OTxnIndex[contractIndex]] == 2) {
            ++OTxnIndex[OSmartContractIndex];
            OSmartContracts[OSmartContractIndex][OTxnIndex[OSmartContractIndex]] = stateIPFSHash;
            OSmartContractState[OSmartContractIndex][OTxnIndex[OSmartContractIndex]] = 1;
            OSmartContractVotes[OSmartContractIndex][OTxnIndex[OSmartContractIndex]] = stakeholderVotes[stakeholderMap[msg.sender]];
            verifyTxn(contractIndex, OTxnIndex[OSmartContractIndex]);
            return OSmartContractIndex;
        }else{
            return 0;
        }
    }
    
    function verifyTxn(uint contractIndex, uint txnIndex) {
        if (stakeholderMap[msg.sender]>0 &&  OSmartContractState[contractIndex][OTxnIndex[contractIndex]] == 2) {
            OSmartContractVotes[contractIndex][txnIndex] += stakeholderVotes[stakeholderMap[msg.sender]];
            if (OSmartContractVotes[contractIndex][txnIndex]>=requiredVotes){
                ++OTxnIndex[OSmartContractIndex];
                OSmartContractState[OSmartContractIndex][txnIndex] = 2;
                txnVerified(contractIndex, txnIndex);
            }
        }
    }
    
    function getClassFile(uint contractIndex) constant returns (string) {
        return ClassFiles[contractIndex];
    }
    
    function getLatestStateFile(uint contractIndex) constant returns (string) {
        return OSmartContracts[contractIndex][OTxnIndex[OSmartContractIndex]];
    }
}