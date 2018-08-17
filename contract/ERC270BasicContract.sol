pragma solidity ^0.4.21;
/**
* Version: 0.1.0
*  The ERC-270 is an Equity Agreement Standard used for smart contracts on Ethereum
* blockchain for project equity allocation.
*  The current ERC270 agreement standard version is 0.1.0, which includes the basic 
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


contract ERC270Interface {
    function name() external view returns (string _name);
    function FasNum() external view returns (uint256 _FasNum);
    function owner() external view returns (address _owner);
    function createTime() external view returns (uint256 _createTime);
    function balanceOf(address _owner) public view returns (uint256 _balance);
    function ownerOf(uint256 _FasId) public view returns (address _owner);
    function exists(uint256 _FasId) public view returns (bool);
    function getTransferRecords(uint256 _FasId) public view returns (address[] _preOwners);
    function transfer(address _to, uint256[] _FasId) public;

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _FasId
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
            FasOwner[i] = project_owner;
            ownedFasCount[project_owner] = ownedFasCount[project_owner].add(1);

            address[1] memory preOwnerList = [project_owner];
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
        address owner = ownerOf(_FasId);
        return (_spender == owner);
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
            require(isOwner(msg.sender, _FasId[i]));
            require(_to != address(0));

            transferRecord(_to, _FasId[i]);
            removeFasFrom(msg.sender, _FasId[i]);
            addFasTo(_to, _FasId[i]);

            emit Transfer(msg.sender, _to, _FasId[i]);
        }
    }

    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () public payable {
        revert();
    }
}