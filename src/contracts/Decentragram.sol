pragma solidity ^0.5.0;

contract Decentragram {
  string public name = "Decentragram";

  // Store images
  uint public imageCount = 0;
  mapping(uint => Image) public images;

  // struct allows us to create a type
  struct Image {
    uint id;
    string hash;
    string description;
    uint tipAmount;
    address payable author; 
  }

  // event store args passed in transaction logs
  event ImageCreated(
    uint id, 
    string hash,
    string description,
    uint tipAmount,
    address payable author
  );

  event ImageTipped(
    uint id,
    string hash,
    string description,
    uint tipAmount,
    address payable author
  );

  // Create images
  function uploadImage(string memory _imgHash, string memory _desc) public {
    // make sure image hash and desc exist
    require(bytes(_desc).length > 0);
    require(bytes(_imgHash).length > 0);
    require(msg.sender != address(0x0));    // empty address 0x0

    // increment image id
    imageCount++;

    // add image to contract
    images[imageCount] = Image(imageCount, _imgHash, _desc, 0, msg.sender);

    // trigger event with the "emit" keyword
    emit ImageCreated(imageCount, _imgHash, _desc, 0, msg.sender);
  }

  // Tip images
  function tipImageOwner (uint _id) public payable {
    require(_id > 0 && _id <= imageCount);

    // fetch image from storage memory
    Image memory _image = images[_id];
    // fetch image author
    address payable _author = _image.author;
    // send crypto            // ref the amount of ETH sent
    address(_author).transfer(msg.value);
    // increment tip amount
    _image.tipAmount += msg.value;
    // update image
    images[_id] = _image;

    // trigger event
    emit ImageTipped(_id, _image.hash, _image.description, _image.tipAmount, _author);
  }
}