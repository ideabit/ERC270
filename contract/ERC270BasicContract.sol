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


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address internal project_owner;
    address internal new_project_owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    /**
    * @dev Gets the project owner
    * @return string representing the project owner
    */
    function owner() external view returns (string) {
        return project_owner;
    }

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


contract ERC270BasicContract is Owned {
    using SafeMath for uint256;

    // Project Name
    string internal proejct_name;

    // Project Fas Number
    uint internal project_fas_number;

    // Project Create Time
    uint internal project_create_time;

    /**
    * @dev Constructor function
    */
    constructor(string _project_name, uint _project_fas_number) public {
        proejct_name = _project_name;
        project_fas_number = _project_fas_number;
        project_create_time = block.timestamp;
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
    function FasNum() external view returns (uint) {
        return project_fas_number;
    }

    /**
    * @dev Gets the project create time
    * @return string representing the project create time
    */
    function createTime() external view returns (uint) {
        return project_create_time;
    }

    // Mapping from Fas ID to owner
    mapping (uint256 => address) internal FasOwner;

    // Mapping from owner to number of owned Fas
    mapping (address => uint256) internal ownedFasCount;

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

    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () public payable {
        revert();
    }
}