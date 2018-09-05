# ERC270 Technical Documentation

## Version : 0.1.5

- [ERC270 Technical Documentation](#erc270-technical-documentation)
    - [Version : 0.1.5](#version--015)
    - [created: 2018-09-04](#created-2018-09-04)
    - [Simple Summary](#simple-summary)
    - [Abstract](#abstract)
    - [Motivation](#motivation)
    - [Specification](#specification)
        - [FAS](#fas)
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

## created: 2018-09-04

## Simple Summary

An equity agreement standard.

## Abstract

The following is a standard that allows for the implementation of equity allocation and related functions within smart contracts. This standard allows for the functions of querying basic project and equity information, track the history of equity transfers, transfer equity, and distribute profits based on equity allocation.

## Motivation

This standard interface allows any project to tokenize their equity, to be protected by the security of Ethereum, and to be used by applications, enabling the transfer of equity from wallet to wallet.

## Specification

### FAS

The Fair and Autonomous Stakeholder-equity protocol (FAS) is a standardized smart contract designed to tokenize how equity works. By implementing this with blockchain technology, precisely smart contracts, it enables tokenized equity to operate on a fair and autonomous basis, allowing the execution of any process to be transparent and pre-determined by the contract. This equity agreement standard allows for the querying of project and equity information, transfer of equity, distribution of profits and voting-related actions.

### Methods

#### name

``` js
function name() external view returns (string _name)
```

Return the name of the project - e.g. `"MyProject"`

Return type `string`

#### FasNum

``` js
function FasNum() external view returns (uint256 _FasNum)
```

Return the number of total FAS created in the project - e.g. `100`

Return type `uint256`

#### owner

``` js
function owner() external view returns (address _owner)
```

Return the address of the project owner - e.g. `0xca35b7d915458ef540ade6068dfe2f44e8fa733c`

Return type `address`

#### createTime

``` js
function createTime() external view returns (uint256 _createTime)
```

Return the timestamp of the project creation time - e.g. `1534431600`

Return type `uint256`

#### balanceOf

``` js
function balanceOf(address _owner) public view returns (uint256 _balance)
```

Return the FAS number owned by the address `_owner` - e.g. `15`

Return type `uint256`

#### ownerOf

``` js
function ownerOf(uint256 _FasId) public view returns (address _owner)
```

Return the address of the FAS owner for `_FasId` - e.g. `0xca35b7d915458ef540ade6068dfe2f44e8fa733c`

Return type `address`

#### exists

``` js
function exists(uint256 _FasId) public view returns (bool)
```

Confirm the validity for the Fas with the FAS ID `_FasId`

#### allOwnedFas

``` js
function allOwnedFas(address _owner) public view returns (uint256[] _allOwnedFasList)
```

Return the list of FAS ID for the FAS owned by the address `_owner` - e.g. `[0,1,2,3,4]`

Return type `uint256[]`

#### getTransferRecords

``` js
function getTransferRecords(uint256 _FasId) public view returns (address[] _preOwners)
```

Return the list of transferor addresses for the FAS with FAS ID `_FasId` and arrange the list as the order of transferring - e.g. `[0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c,0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C]`

Return type `address[]`

#### transfer

``` js
function transfer(address _to, uint256[] _FasId) public
```

Transfer the FAS with FAS ID `_FasId` (the number of FAS transferred here can be multiple by a list of FAS ID) to the address `_to`，and trigger the event `Transfer`

If the transferor attempts to send a FAS that does belong to him or a FAS that does not exist, the function will be broke.

#### createVote

``` js
function createVote() public payable returns (uint256 _voteId)
```

Creat a voting event，and return the Vote ID `_voteId`

Return type `uint256`

#### vote

``` js
function vote(uint256 _voteId, uint256 _vote_status_value) public
```

Vote for the event with the Vote ID `_voteId`. In the voting event，value `0` for `_vote_status_value` means affirmative vote，value `1` for `_vote_status_value` means dissenting vote，and value `2` means abstaining.

#### getVoteResult

``` js
function getVoteResult(uint256 _voteId) public payable returns (bool result)
```

Obtain the voting result of the event with Vote ID `_voteId`. return `true` if the voting event got successful, and return `false` if not.

Return type `bool`

#### dividend

``` js
function dividend(address _token_owner) public
```

Distribute bonus from the wallet address `_token_owner` to all the Fas owners.

### Event

#### Transfer

``` js
event Transfer(address indexed _from, address indexed _to, uint256 indexed _FasId);
```

Will be triggered when transferring Fas, including transferring 0 FAS

#### Vote

``` js
event Vote(uint256 _voteId);
```

Will be triggered when creating a voting event

## Test Cases

### Test Cases are available at

- https://github.com/ideabit/ERC270/blob/master/contract/ERC270BasicContract.sol

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).