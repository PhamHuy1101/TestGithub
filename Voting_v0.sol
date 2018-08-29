pragma solidity ^0.4.10;

contract Voting {
    
    uint deadline;
    uint totalCoins;
    uint numberOfCadidates;
    
    struct Cadidates {
        mapping(address => bool) voted;
        address[] votersAddress;
    }
    
    mapping (uint => Cadidates) cadidates;
    
    event Vote(address from, uint _cadidateId);
    
    constructor(uint _numberOfCadidates) public {
        deadline = 0 minutes;
        totalCoins = 0;
        numberOfCadidates = _numberOfCadidates;
    }
    
    modifier isStart() {
        require(deadline > 0);
        _;
    }
    
    modifier isValidCodidateId(uint id) {
        require(id < numberOfCadidates);
        _;
    }
    function startGame(uint _mins) public {
        deadline = now + _mins * 1 minutes;
    }
    
    function _vote(uint _cadidateId) payable public isStart isValidCodidateId(_cadidateId) {
        //require (cadidates[_cadidateId].voted[msg.sender] == false);
        
        cadidates[_cadidateId].voted[msg.sender] = true;
        cadidates[_cadidateId].votersAddress.push(msg.sender);
        
        emit Vote(msg.sender, _cadidateId);
    }
    
    function vote(uint[] _cadidatesId) payable public isStart {
        require(deadline > 0);
        require(msg.value >= _cadidatesId.length);
        
        uint i;
        for (i = 0; i < _cadidatesId.length; i++) {
            _vote(_cadidatesId[i]);
        }
    }
    
    function endGame() payable public returns(bool) {
        require(deadline < now);
        
        uint winId = 0;
        uint winCount = 0;
        uint i;
        uint j;
        for(i = 1; i < numberOfCadidates; i++) {
            if (cadidates[i].votersAddress.length >= cadidates[winId].votersAddress.length) {
                if (cadidates[i].votersAddress.length == cadidates[winId].votersAddress.length)
                    winCount++;
                else {
                    winCount = 0;
                    winId = i;
                }
            }
        }
        
        if (winCount > 1) {
            // tra lai tien cho moi nguoi
            for (i = 0; i < numberOfCadidates; i++) {
                for (j = 0; j < cadidates[i].votersAddress.length; j++) {
                    cadidates[i].votersAddress[j].transfer(1 ether);
                }
            }
            return false;
        }
        else {
            uint amountOfCoins = uint(totalCoins / cadidates[winId].votersAddress.length);
            for (i = 0; i < cadidates[winId].votersAddress.length; i++) {
                cadidates[winId].votersAddress[i].transfer(amountOfCoins * 1 ether);
            }
            
            msg.sender.transfer(totalCoins % cadidates[winId].votersAddress.length);
            return true;
        }
    }
    
}


// version 2
//##############################################################################################
pragma solidity ^0.4.10;

contract owned {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

contract Voting is owned {
    
    uint deadline;
    uint totalCoins;
    uint numberOfCadidates;
    
    struct Cadidates {
        mapping(address => bool) voted;
        address[] votersAddress;
    }
    
    mapping (uint => Cadidates) cadidates;
    
    event Vote(address from, uint _cadidateId);
    
    constructor(uint _numberOfCadidates) owned() public {
        deadline = 0 minutes;
        totalCoins = 0;
        numberOfCadidates = _numberOfCadidates;
    }
    
    modifier isStart() {
        require(deadline > 0);
        _;
    }
    
    modifier isValidCodidateId(uint id) {
        require(id < numberOfCadidates);
        _;
    }
    function startGame(uint _mins) public onlyOwner {
        deadline = now + _mins * 1 minutes;
    }
    
    function _vote(uint _cadidateId) payable public isStart isValidCodidateId(_cadidateId) {
        require (cadidates[_cadidateId].voted[msg.sender] == false);
        
        cadidates[_cadidateId].voted[msg.sender] = true;
        cadidates[_cadidateId].votersAddress.push(msg.sender);
        
        emit Vote(msg.sender, _cadidateId);
    }
    
    function vote(uint[] _cadidatesId) payable public isStart {
        require(msg.value >= _cadidatesId.length);
        
        uint i;
        for (i = 0; i < _cadidatesId.length; i++) {
            _vote(_cadidatesId[i]);
        }
    }
    
    function endGame() payable public onlyOwner returns(bool) {
        require(deadline < now);
        
        uint winId = 0;
        uint winCount = 0;
        uint i;
        uint j;
        for(i = 1; i < numberOfCadidates; i++) {
            if (cadidates[i].votersAddress.length >= cadidates[winId].votersAddress.length) {
                if (cadidates[i].votersAddress.length == cadidates[winId].votersAddress.length)
                    winCount++;
                else {
                    winCount = 0;
                    winId = i;
                }
            }
        }
        
        if (winCount > 1) {
            // turn money for each player
            for (i = 0; i < numberOfCadidates; i++) {
                for (j = 0; j < cadidates[i].votersAddress.length; j++) {
                    cadidates[i].votersAddress[j].transfer(1 ether);
                }
            }
            return false;
        }
        else {
            // turn money for winners
            uint amountOfCoins = uint(totalCoins / cadidates[winId].votersAddress.length);
            for (i = 0; i < cadidates[winId].votersAddress.length; i++) {
                cadidates[winId].votersAddress[i].transfer(amountOfCoins * 1 ether);
            }
            // give a bit coins for admin. Who started games
            msg.sender.transfer(totalCoins % cadidates[winId].votersAddress.length);
            return true;
        }
    }
    
}