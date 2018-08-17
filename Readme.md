# ERC270技术文档

## Version : 0.1.0

## 概述

ERC270是一个股权标准协议，通过智能合约，来解决以太坊区块链中的项目股权分配的问题。通过ERC270协议，使用者可以查询项目基本信息以及股权信息，追踪股权转让历史以及转让股权。使用者也可以扩展该协议，与ERC20标准合约结合，增加售卖持有股权，以及依据股权分配情况，分配股权收益等功能。

## ERC270接口

ERC270作为一个股权标准协议，提供了要实现ERC270股权标准协议时必须实现的接口，接口定义如下：

``` js
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
```

### Methods

#### name

``` js
function name() external view returns (string _name)
```

返回本项目名称 - e.g. `"MyProject"`

返回类型 `string`

#### FasNum

``` js
function FasNum() external view returns (uint256 _FasNum)
```

返回本项目创建的股权总数量 - e.g. `100`

返回类型 `uint256`

#### owner

``` js
function owner() external view returns (address _owner)
```

返回本项目所有者地址 - e.g. `0xca35b7d915458ef540ade6068dfe2f44e8fa733c`

返回类型 `address`

#### createTime

``` js
function createTime() external view returns (uint256 _createTime)
```

返回本项目创建时间的时间戳 - e.g. `1534431600`

返回类型 `uint256`

#### balanceOf

``` js
function balanceOf(address _owner) public view returns (uint256 _balance)
```

返回地址为`_owner`的账户所持有的Fas数量 - e.g. `15`

返回类型 `uint256`

#### ownerOf

``` js
function ownerOf(uint256 _FasId) public view returns (address _owner)
```

返回Fas ID为`_FasId`的Fas的持有者地址 - e.g. `0xca35b7d915458ef540ade6068dfe2f44e8fa733c`

返回类型 `address`

#### exists

``` js
function exists(uint256 _FasId) public view returns (bool)
```

确认Fas ID为`_FasId`的Fas是否为有效Fas

#### getTransferRecords

``` js
function getTransferRecords(uint256 _FasId) public view returns (address[] _preOwners)
```

返回Fas ID为`_FasId`的Fas的转让者地址名单，并按转让顺序排列 - e.g. `[0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c,0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C]`

返回类型 `address[]`

#### transfer

``` js
function transfer(address _to, uint256[] _FasId) public
```

向地址为`_to`的持有者转让自己持有的Fas ID为`_FasId`的复数Fas，且必须触发`Transfer`事件

如果发送者无足够的Fas可以转让，则退出该函数

### Event

#### Transfer

``` js
event Transfer(address indexed _from, address indexed _to, uint256 indexed _FasId);
```

转让Fas时必须触发，包括转让值为0