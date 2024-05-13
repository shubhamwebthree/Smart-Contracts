// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.9.0;

contract TweetContract {
    struct Tweet {
        uint256 id;
        address author;
        string content;
        uint256 createdAt;
    }

    struct Message {
        uint256 id;
        string content;
        address from;
        address to;
        uint256 createdAt;
    }

    mapping(uint256 => Tweet) public tweets;

    mapping(address => uint256[]) public tweetsOf; //0xabc - 2,10,15,19,20,22

    mapping(address => Message[]) public conversations;

    mapping(address => mapping(address => bool)) public operators;

    mapping(address => address[]) public following;

    uint256 nextId; //0

    uint256 nextMessageId;

    function _tweet(address _from, string memory _content) internal {
        //tweet access check - owner,authority
        require(_from == msg.sender || operators[_from][msg.sender],"You don't have access");
        tweets[nextId] = Tweet(nextId, _from, _content, block.timestamp);
        tweetsOf[_from].push(nextId);
        nextId = nextId + 1;
    }

    function _sendMessage(address _from,address _to,string memory _content) internal {
        //tweet access check - owner,authority
        require(_from == msg.sender || operators[_from][msg.sender],"You don't have access");
        conversations[_from].push(Message(nextMessageId, _content, _from, _to, block.timestamp));
        nextMessageId++;
    }

    //owner
    function tweet(string memory _content) public {
        _tweet(msg.sender, _content);
    }

    //owner->address access
    function tweet(address _from, string memory _content) public {
        _tweet(_from, _content);
    }

    //owner
    function sendMessage(string memory _content, address _to) public {
        _sendMessage(msg.sender, _to, _content);
    }

    //owner - address access
    function sendMessage(address _from,address _to,string memory _content) public {
    _sendMessage(_from, _to, _content);
    }

    function follow(address _followed) public {
    following[msg.sender].push(_followed);
    }
    
    function allow(address _operator) public {
        operators[msg.sender][_operator] = true;
    }

    function disallow(address _operator) public {
        operators[msg.sender][_operator] = false;
    }

    function getLatestTweets(uint256 count) public view returns (Tweet[] memory){
        require(count > 0 && count <= nextId, "Count is not proper");
        Tweet[] memory _tweets = new Tweet[](count); //array length - count
        uint256 j;
        //count = 5 nextId=7; 7-5=2,3,4,5,6
        for (uint256 i = nextId - count; i < nextId; i++) {
            Tweet storage _structure = tweets[i];
            _tweets[j] = Tweet(
                _structure.id,
                _structure.author,
                _structure.content,
                _structure.createdAt
            );
            j = j + 1;
        }
        return _tweets;
    }
        //7
    function getLatestofUser(address _user, uint256 count) public view returns (Tweet[] memory){
        Tweet[] memory _tweets = new Tweet[](count); //new memory array whoose length is count
        //tweetsOf[_user] is having all the id's of the user
        uint256[] memory ids = tweetsOf[_user]; ///ids is an array
        require(count > 0 && count <= ids.length, "Count is not defined");
        uint256 j;
            //5-3 = 2 to 5
        for (uint256 i = ids.length - count; i < ids.length; i++) {
            Tweet storage _structure = tweets[ids[i]]; //i=2 id[2]=15 tweets[15]
            _tweets[j] = Tweet(
                _structure.id,
                _structure.author,
                _structure.content,
                _structure.createdAt
            );
            j = j + 1;
        }
        return _tweets;
    }
}
