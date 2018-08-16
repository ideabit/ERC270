pragma solidity ^0.4.21;


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


contract ERC270Interface {
    function name() external view returns (string _name);
    function FasNum() external view returns (uint256 _FasNum);
    function createTime() external view returns (uint256 _createTime);
    function balanceOf(address _owner) public view returns (uint256 _balance);
    function ownerOf(uint256 _FasId) public view returns (address _owner);
    function exists(uint256 _FasId) public view returns (bool);
    function approve(address _to, uint256 _FasId) public;
    function getApproved(uint256 _FasId) public view returns (address _operator);
    function setApprovalForAll(address _to, bool _approved) public;
    function isApprovedForAll(address _owner, address _operator) public view returns (bool);
    function getTransferRecords(uint256 _FasId) public view returns (address[] _preOwners);
    function transfer(address _to, uint256[] _FasId) public;
    function transferFrom(address _from, address _to, uint256[] _FasId) public;

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _FasId
    );
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _FasId
    );
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );
}


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address internal project_owner;
    address internal new_project_owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() public {
        project_owner = msg.sender;
    }

    /**
    * @dev Gets the project owner
    * @return string representing the project owner
    */
    function owner() external view returns (address) {
        return project_owner;
    }

    modifier onlyOwner {
        require(msg.sender == project_owner);
        _;
    }

    function transferOwnership(address _new_project_owner) public onlyOwner {
        new_project_owner = _new_project_owner;
    }

    function acceptOwnership() public {
        require(msg.sender == new_project_owner);
        emit OwnershipTransferred(project_owner, new_project_owner);
        project_owner = new_project_owner;
        new_project_owner = address(0);
    }
}


contract ERC270BasicContract is ERC270Interface, Owned {
    using SafeMath for uint256;

    // Project Name
    string internal proejct_name;

    // Project Fas Number
    uint256 internal project_fas_number;

    // Project Create Time
    uint256 internal project_create_time;

    /**
    * @dev Constructor function
    */
    constructor(string _project_name) public {
        proejct_name = _project_name;
        project_fas_number = 100;
        project_create_time = block.timestamp;

        for(uint i = 0; i < project_fas_number; i++)
        {
            FasOwner[i] = address(0);
            ownedFasCount[address(0)] = ownedFasCount[address(0)].add(1);

            address[1] memory preOwnerList = [address(0)];
            transferRecords[i] = preOwnerList;
        }
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
    * @return string representing the project Fas number
    */
    function FasNum() external view returns (uint256) {
        return project_fas_number;
    }

    /**
    * @dev Gets the project create time
    * @return string representing the project create time
    */
    function createTime() external view returns (uint256) {
        return project_create_time;
    }

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
        address owner = FasOwner[_FasId];
        require(owner != address(0));
        return owner;
    }

    /**
    * @dev Returns whether the specified Fas exists
    * @param _FasId uint256 ID of the Fas to query the existence of
    * @return whether the Fas exists
    */
    function exists(uint256 _FasId) public view returns (bool) {
        address owner = FasOwner[_FasId];
        return owner != address(0);
    }

    /**
    * @dev Approves another address to transfer the given Fas ID
    * The zero address indicates there is no approved address.
    * There can only be one approved address per Fas at a given time.
    * Can only be called by the Fas owner or an approved operator.
    * @param _to address to be approved for the given Fas ID
    * @param _FasId uint256 ID of the Fas to be approved
    */
    function approve(address _to, uint256 _FasId) public {
        address owner = ownerOf(_FasId);
        require(_to != owner);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

        FasApprovals[_FasId] = _to;
        emit Approval(owner, _to, _FasId);
    }

    /**
    * @dev Gets the approved address for a Fas ID, or zero if no address set
    * @param _FasId uint256 ID of the Fas to query the approval of
    * @return address currently approved for the given Fas ID
    */
    function getApproved(uint256 _FasId) public view returns (address) {
        return FasApprovals[_FasId];
    }

    /**
    * @dev Sets or unsets the approval of a given operator
    * An operator is allowed to transfer all tokens of the sender on their behalf
    * @param _to operator address to set the approval
    * @param _approved representing the status of the approval to be set
    */
    function setApprovalForAll(address _to, bool _approved) public {
        require(_to != msg.sender);
        operatorApprovals[msg.sender][_to] = _approved;
        emit ApprovalForAll(msg.sender, _to, _approved);
    }

    /**
    * @dev Tells whether an operator is approved by a given owner
    * @param _owner owner address which you want to query the approval of
    * @param _operator operator address which you want to query the approval of
    * @return bool whether the given operator is approved by the given owner
    */
    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
        return operatorApprovals[_owner][_operator];
    }

    /**
    * @dev Internal function to clear current approval of a given Fas ID
    * Reverts if the given address is not indeed the owner of the Fas
    * @param _owner owner of the Fas
    * @param _FasId uint256 ID of the Fas to be transferred
    */
    function clearApproval(address _owner, uint256 _FasId) internal {
        require(ownerOf(_FasId) == _owner);
        if (FasApprovals[_FasId] != address(0)) {
            FasApprovals[_FasId] = address(0);
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
    function isApprovedOrOwner(address _spender, uint256 _FasId) internal view returns (bool){
        address owner = ownerOf(_FasId);
        return (_spender == owner || getApproved(_FasId) == _spender || isApprovedForAll(owner, _spender));
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
    * @param _to address to receive the ownership of the given Fas ID
    * @param _FasId uint256 ID of the Fas to be transferred
    */
    function transfer(address _to, uint256[] _FasId) public{
        for(uint i = 0; i < _FasId.length; i++)
        {
            require(isApprovedOrOwner(msg.sender, _FasId[i]));
            require(_to != address(0));

            transferRecord(_to, _FasId[i]);
            removeFasFrom(msg.sender, _FasId[i]);
            addFasTo(_to, _FasId[i]);

            emit Transfer(msg.sender, _to, _FasId[i]);
        }
    }

    /**
    * @dev Transfers the ownership of a given Fas ID to another address
    * Requires the msg sender to be the owner, approved, or operator
    * @param _from current owner of the Fas
    * @param _to address to receive the ownership of the given Fas ID
    * @param _FasId uint256 ID of the Fas to be transferred
    */
    function transferFrom(address _from, address _to, uint256[] _FasId) public{
        for(uint i = 0; i < _FasId.length; i++)
        {
            require(isApprovedOrOwner(msg.sender, _FasId[i]));
            require(_from != address(0));
            require(_to != address(0));

            transferRecord(_to, _FasId[i]);
            clearApproval(_from, _FasId[i]);
            removeFasFrom(_from, _FasId[i]);
            addFasTo(_to, _FasId[i]);

            emit Transfer(_from, _to, _FasId[i]);
        }
    }

    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () public payable {
        revert();
    }
}