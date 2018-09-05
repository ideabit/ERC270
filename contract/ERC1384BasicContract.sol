pragma solidity ^0.4.24;
/**
* Version: 0.1.0
*  The ERC-1384 is an Equity Agreement Standard used for smart contracts on Ethereum
* blockchain for project equity allocation.
*  The current ERC-1384 agreement standard version is 0.1.0, which includes the basic 
* information of the project query, equity creation, confirmation of equity validity,
* equity transfer, record of equity transfer and other functions.
*/

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b <= a);
        c = a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b > 0);
        c = a / b;
    }
}


contract ERC20 {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


contract ERC1384Interface {
    function name() external view returns (string _name);
    function FasNum() external view returns (uint256 _FasNum);
    function owner() external view returns (address _owner);
    function createTime() external view returns (uint256 _createTime);
    function balanceOf(address _owner) public view returns (uint256 _balance);
    function ownerOf(uint256 _FasId) public view returns (address _owner);
    function exists(uint256 _FasId) public view returns (bool);
    function allOwnedFas(address _owner) public view returns (uint256[] _allOwnedFasList);
    function getTransferRecords(uint256 _FasId) public view returns (address[] _preOwners);
    function transfer(address _to, uint256[] _FasId) public;
    function createVote() public payable returns (uint256 _voteId);
    function vote(uint256 _voteId, uint256 _vote_status_value) public;
    function getVoteResult(uint256 _voteId) public payable returns (bool result);
    function dividend(address _token_owner) public;

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _FasId
    );
    event Vote(
        uint256 _voteId
    );
}


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address internal project_owner;
    address internal new_project_owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        project_owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == project_owner);
        _;
    }

    function transferOwnership(address _new_project_owner) public onlyOwner {
        new_project_owner = _new_project_owner;
    }
}


contract ERC1384BasicContract is ERC1384Interface, Owned {
    using SafeMath for uint256;

    // Project Name
    string internal proejct_name;

    // Project Fas Number
    uint256 internal project_fas_number;

    // Project Create Time
    uint256 internal project_create_time;

    // Owner Number
    uint256 internal owners_num;

    // Vote Number
    uint256 internal votes_num;

    address internal token_0x_address;

    /**
    * @dev Constructor function
    */
    constructor(string _project_name, address _token_0x_address) public {
        proejct_name = _project_name;
        project_fas_number = 100;
        project_create_time = block.timestamp;
        token_0x_address = _token_0x_address;

        for(uint i = 0; i < project_fas_number; i++)
        {
            FasOwner[i] = project_owner;
            ownedFasCount[project_owner] = ownedFasCount[project_owner].add(1);

            address[1] memory preOwnerList = [project_owner];
            transferRecords[i] = preOwnerList;
        }

        owners_num = 0;
        votes_num = 0;

        ownerExists[project_owner] = true;

        addOwnerNum(project_owner);
    }

    /**
    * @dev Gets the project name
    * @return string representing the project name
    */
    function name() external view returns (string) {
        return proejct_name;
    }

    /**
    * @dev Gets the project Fas number
    * @return uint256 representing the project Fas number
    */
    function FasNum() external view returns (uint256) {
        return project_fas_number;
    }

    /**
    * @dev Gets the project owner
    * @return address representing the project owner
    */
    function owner() external view returns (address) {
        return project_owner;
    }

    /**
    * @dev Gets the project create time
    * @return uint256 representing the project create time
    */
    function createTime() external view returns (uint256) {
        return project_create_time;
    }

    // Mapping from number of owner to owner
    mapping (uint256 => address) internal ownerNum;

    mapping (address => bool) internal ownerExists;

    // Mapping from Fas ID to owner
    mapping (uint256 => address) internal FasOwner;

    // Mapping from owner to number of owned Fas
    mapping (address => uint256) internal ownedFasCount;

    // Mapping from Fas ID to approved address
    mapping (uint256 => address) internal FasApprovals;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) internal operatorApprovals;

    // Mapping from Fas ID to previous owners
    mapping (uint256 => address[]) internal transferRecords;

    // Mapping from vote ID to vote result
    mapping (uint256 => mapping (uint256 => uint256)) internal voteResult;

    function acceptOwnership() public {
        require(msg.sender == new_project_owner);
        emit OwnershipTransferred(project_owner, new_project_owner);

        transferForOwnerShip(project_owner, new_project_owner, allOwnedFas(project_owner));

        project_owner = new_project_owner;
        new_project_owner = address(0);
    }

    /**
    * @dev Gets the balance of the specified address
    * @param _owner address to query the balance of
    * @return uint256 representing the amount owned by the passed address
    */
    function balanceOf(address _owner) public view returns (uint256) {
        require(_owner != address(0));
        return ownedFasCount[_owner];
    }

    /**
    * @dev Gets the owner of the specified Fas ID
    * @param _FasId uint256 ID of the Fas to query the owner of
    * @return owner address currently marked as the owner of the given Fas ID
    */
    function ownerOf(uint256 _FasId) public view returns (address) {
        address _owner = FasOwner[_FasId];
        require(_owner != address(0));
        return _owner;
    }

    /**
    * @dev Returns whether the specified Fas exists
    * @param _FasId uint256 ID of the Fas to query the existence of
    * @return whether the Fas exists
    */
    function exists(uint256 _FasId) public view returns (bool) {
        address _owner = FasOwner[_FasId];
        return _owner != address(0);
    }

    /**
    * @dev Gets the owner of all owned Fas
    * @param _owner address to query the balance of
    * @return the FasId list of owners
    */
    function allOwnedFas(address _owner) public view returns (uint256[]) {
        uint256 _ownedFasCount = ownedFasCount[_owner];
        uint256 j = 0;

        uint256[] memory _allOwnedFasList = new uint256[](_ownedFasCount);

        for(uint256 i = 0; i < project_fas_number; i++)
        {
            if(FasOwner[i] == _owner)
            {
                _allOwnedFasList[j] = i;
                j = j.add(1);
            }
        }

        return _allOwnedFasList;
    }

    /**
    * @dev Internal function to add Owner Count to the list of a given address
    * @param _owner address representing the new owner
    */
    function addOwnerNum(address _owner) internal {
        require(ownedFasCount[_owner] != 0);

        if(ownerExists[_owner] == false)
        {
            ownerNum[owners_num] = _owner;
            owners_num = owners_num.add(1);
            ownerExists[_owner] = true;
        }
    }

    /**
    * @dev Internal function to add a Fas ID to the list of a given address
    * @param _to address representing the new owner of the given Fas ID
    * @param _FasId uint256 ID of the Fas to be added to the Fas list of the given address
    */
    function addFasTo(address _to, uint256 _FasId) internal {
        require(FasOwner[_FasId] == address(0));
        FasOwner[_FasId] = _to;
        ownedFasCount[_to] = ownedFasCount[_to].add(1);
    }

    /**
    * @dev Internal function to remove a Fas ID from the list of a given address
    * @param _from address representing the previous owner of the given Fas ID
    * @param _FasId uint256 ID of the Fas to be removed from the Fas list of the given address
    */
    function removeFasFrom(address _from, uint256 _FasId) internal {
        require(ownerOf(_FasId) == _from);
        ownedFasCount[_from] = ownedFasCount[_from].sub(1);
        FasOwner[_FasId] = address(0);
    }

    /**
    * @dev Returns whether the given spender can transfer a given Fas ID
    * @param _spender address of the spender to query
    * @param _FasId uint256 ID of the Fas to be transferred
    * @return bool whether the msg.sender is approved for the given Fas ID,
    *  is an operator of the owner, or is the owner of the Fas
    */
    function isOwner(address _spender, uint256 _FasId) internal view returns (bool){
        address _owner = ownerOf(_FasId);
        return (_spender == _owner);
    }

    /**
    * @dev Record the transfer records for a Fas ID
    * @param _FasId uint256 ID of the Fas
    * @return bool record
    */
    function transferRecord(address _nowOwner, uint256 _FasId) internal{
        address[] memory preOwnerList = transferRecords[_FasId];
        address[] memory _preOwnerList = new address[](preOwnerList.length + 1);

        for(uint i = 0; i < _preOwnerList.length; ++i)
        {
            if(i != preOwnerList.length)
            {
                _preOwnerList[i] = preOwnerList[i];
            }
            else
            {
                _preOwnerList[i] = _nowOwner;
            }
        }

        transferRecords[_FasId] = _preOwnerList;
    }

    /**
    * @dev Gets the transfer records for a Fas ID
    * @param _FasId uint256 ID of the Fas
    * @return address of previous owners
    */
    function getTransferRecords(uint256 _FasId) public view returns (address[]) {
        return transferRecords[_FasId];
    }

    /**
    * @dev Transfers the ownership of a given Fas ID to a specified address
    * @param _project_owner the address of _project_owner
    * @param _to address to receive the ownership of the given Fas ID
    * @param _FasId uint256 ID of the Fas to be transferred
    */
    function transferForOwnerShip(address _project_owner,address _to, uint256[] _FasId) internal{
        for(uint i = 0; i < _FasId.length; i++)
        {
            require(isOwner(_project_owner, _FasId[i]));
            require(_to != address(0));

            transferRecord(_to, _FasId[i]);
            removeFasFrom(_project_owner, _FasId[i]);
            addFasTo(_to, _FasId[i]);
        }

        addOwnerNum(_to);
    }

    /**
    * @dev Transfers the ownership of a given Fas ID to a specified address
    * @param _to address to receive the ownership of the given Fas ID
    * @param _FasId uint256 ID of the Fas to be transferred
    */
    function transfer(address _to, uint256[] _FasId) public{
        for(uint i = 0; i < _FasId.length; i++)
        {
            require(isOwner(msg.sender, _FasId[i]));
            require(_to != address(0));

            transferRecord(_to, _FasId[i]);
            removeFasFrom(msg.sender, _FasId[i]);
            addFasTo(_to, _FasId[i]);

            emit Transfer(msg.sender, _to, _FasId[i]);
        }

        addOwnerNum(_to);
    }

    /**
    * @dev Create a new vote
    * @return the new vote of ID
    */
    function createVote() public payable returns (uint256){
        votes_num = votes_num.add(1);

        // Vote Agree Number
        voteResult[votes_num][0] = 0;
        // Vote Disagree Number
        voteResult[votes_num][1] = 0;
        // Vote Abstain Number
        voteResult[votes_num][2] = 0;
        // Start Voting Time
        voteResult[votes_num][3] = block.timestamp;

        emit Vote(votes_num);

        return votes_num;
    }

    /**
    * @dev Voting for a given vote ID
    * @param _voteId the given vote ID
    * @param _vote_status_value uint256 the vote of status, 0 Agree, 1 Disagree, 2 Abstain
    */
    function vote(uint256 _voteId, uint256 _vote_status_value) public{
        require(_vote_status_value >= 0);
        require(_vote_status_value <= 2);

        require(block.timestamp <= (voteResult[_voteId][3] + 1 days));

        uint256 temp_Fas_count = balanceOf(msg.sender);

        if(_vote_status_value == 0)
        {
            voteResult[_voteId][0] = voteResult[_voteId][0].add(temp_Fas_count);
        }
        else if(_vote_status_value == 1)
        {
            voteResult[_voteId][1] = voteResult[_voteId][1].add(temp_Fas_count);
        }
        else
        {
            voteResult[_voteId][2] = voteResult[_voteId][2].add(temp_Fas_count);
        }
    }

    /**
    * @dev Gets the voting restult for a vote ID
    * @param _voteId the given vote ID
    * @return the voting restult, true success, false failure
    */
    function getVoteResult(uint256 _voteId) public payable returns (bool){
        require(block.timestamp > (voteResult[_voteId][3] + 1 days));

        uint agree_num = voteResult[_voteId][0];
        uint disagree_num = voteResult[_voteId][1];
        uint abstain_num = voteResult[_voteId][2];
        uint temp_abstain_num = 100 - agree_num - disagree_num;

        if(temp_abstain_num != abstain_num)
        {
            voteResult[_voteId][2] = temp_abstain_num;
        }

        if(agree_num > disagree_num)
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    /**
    * @dev Distribution of benefits
    * @param _token_owner Divider's Token address
    */
    function dividend(address _token_owner) public{
        uint256 temp_allowance = ERC20(token_0x_address).allowance(_token_owner, address(this));

        for(uint i = 0; i < owners_num; i++)
        {
            uint256 temp_Fas_count = balanceOf(ownerNum[i]);

            uint256 _dividend = temp_allowance * temp_Fas_count / 100;
            ERC20(token_0x_address).transferFrom(_token_owner, ownerNum[i], _dividend);
        }
    }

    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () public payable {
        revert();
    }
}