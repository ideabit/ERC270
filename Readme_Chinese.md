# ERC-1384技术文档

## Version : 0.1.5

- [ERC-1384技术文档](#erc-1384%E6%8A%80%E6%9C%AF%E6%96%87%E6%A1%A3)
    - [Version : 0.1.5](#version--015)
    - [created: 2018-09-05](#created-2018-09-05)
    - [Simple Summary](#simple-summary)
    - [Abstract](#abstract)
    - [Motivation](#motivation)
    - [Specification](#specification)
        - [Methods](#methods)
            - [name](#name)
            - [FasNum](#fasnum)
            - [owner](#owner)
            - [createTime](#createtime)
            - [balanceOf](#balanceof)
            - [ownerOf](#ownerof)
            - [exists](#exists)
            - [allOwnedFas](#allownedfas)
            - [getTransferRecords](#gettransferrecords)
            - [transfer](#transfer)
            - [createVote](#createvote)
            - [vote](#vote)
            - [getVoteResult](#getvoteresult)
            - [dividend](#dividend)
        - [Event](#event)
            - [Transfer](#transfer)
            - [Vote](#vote)
    - [Test Cases](#test-cases)
        - [Test Cases are available at](#test-cases-are-available-at)
    - [Copyright](#copyright)

## created: 2018-09-05

## Simple Summary

An equity agreement standard.

## Abstract

The following is a standard that allows for the implementation of equity allocation and related functions within smart contracts. This standard allows for the functions of querying basic project and equity information, track the history of equity transfers, transfer equity, and distribute profits based on equity allocation.

## Motivation

This standard interface allows any project to tokenize their equity, to be protected by the security of Ethereum, and to be used by applications, enabling the transfer of equity from wallet to wallet.

## Specification

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

#### allOwnedFas

``` js
function allOwnedFas(address _owner) public view returns (uint256[] _allOwnedFasList)
```

返回持有者地位为`_owner`的全部的Fas ID列表 - e.g. `[0,1,2,3,4]`

返回类型 `uint256[]`

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

#### createVote

``` js
function createVote() public payable returns (uint256 _voteId)
```

创建投票事件，并返回Vote ID `_voteId`

返回类型 `uint256`

#### vote

``` js
function vote(uint256 _voteId, uint256 _vote_status_value) public
```

进行投票，根据Vote ID `_voteId`，在该ID的投票事件中进行投票，`_vote_status_value`为`0`代表赞同，为`1`代表反对，为`2`代表弃权

#### getVoteResult

``` js
function getVoteResult(uint256 _voteId) public payable returns (bool result)
```

获取投票事件的Vote ID为`_voteId`的投票结果，返回`true`为成功，返回`false`为失败

返回类型 `bool`

#### dividend

``` js
function dividend(address _token_owner) public
```

分配红利，从地址为`_token_owner`的地址中，向所有的Fas持有者的地址分配红利

### Event

#### Transfer

``` js
event Transfer(address indexed _from, address indexed _to, uint256 indexed _FasId);
```

转让Fas时必须触发，包括转让值为0

#### Vote

``` js
event Vote(uint256 _voteId);
```

创建投票事件时必须触发

## Test Cases

### Test Cases are available at

- https://github.com/ideabit/ERC270/blob/master/contract/ERC270BasicContract.sol

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).