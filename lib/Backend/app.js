const express = require("express");
const app = express();
const path = require("path");
const fs = require("fs");
const dns = require('dns');
const axios = require("axios");
const { clear } = require("console");
const { Server } = require("http");

var MovieDirectory=""
var IP=""

// Specify the path to the text file
const filePath = 'C:/Users/Deepu/Documents/Config.txt';

// Read file asynchronously
fs.readFile(filePath, 'utf8', (err, data) => {
    if (err) {
        console.error('Error reading file:', err);
        return;
    }
    MovieDirectory=data.split(",")[0].split("-")[1]
    IP=data.split(",")[1].split("-")[1]
    // You can process the file content here
});

app.get("/showSeries/*", (req, res) => {
  console.log(req.url)
  console.log( req.url.split("/")[2])
  const videoFilePath = path.resolve(
    MovieDirectory,
    req.url.split("/")[2].replaceAll("$"," ")+"/"+ req.url.split("/")[3].replaceAll("$"," ")+"/"+ req.url.split("/")[4].replaceAll("$"," ")
  );
  console.log(__dirname);
  const videoStat = fs.statSync(videoFilePath);
  const fileSize = videoStat.size;

  const range = req.headers.range;
  if (range) {
    const parts = range.replace(/bytes=/, "").split("-");
    const start = parseInt(parts[0], 10);
    const end = parts[1] ? parseInt(parts[1], 10) : fileSize - 1;

    const chunkSize = end - start + 1;
    const fileStream = fs.createReadStream(videoFilePath, { start, end });

    res.writeHead(206, {
      "Content-Range": `bytes ${start}-${end}/${fileSize}`,
      "Accept-Ranges": "bytes",
      "Content-Length": chunkSize,
      "Content-Type": "video/mp4",
    });

    fileStream.pipe(res);
  } else {
    res.writeHead(200, {
      "Content-Length": fileSize,
      "Content-Type": "video/mp4",
    });

    fs.createReadStream(videoFilePath).pipe(res);
  }

  /*
  
    // Set the content type header
    res.setHeader('Accept-Ranges', 'bytes');
  
  
   
  
   
    // Stream the video file
    console.log("\n\n\n\n\n\n\n"+req.url+"\n\n\n\n\n")
    const videoStream = fs.createReadStream(videoFilePath);
    videoStream.pipe(res); */
});



app.get("/showMovie", (req, res) => {
  console.log(req.query.name)

  const videoFilePath = path.resolve(
    MovieDirectory,
    req.query.name.replaceAll("$"," ")+"/"
  );
  console.log(__dirname);
  const videoStat = fs.statSync(videoFilePath);
  const fileSize = videoStat.size;

  const range = req.headers.range;
  if (range) {
    const parts = range.replace(/bytes=/, "").split("-");
    const start = parseInt(parts[0], 10);
    const end = parts[1] ? parseInt(parts[1], 10) : fileSize - 1;

    const chunkSize = end - start + 1;
    const fileStream = fs.createReadStream(videoFilePath, { start, end });

    res.writeHead(206, {
      "Content-Range": `bytes ${start}-${end}/${fileSize}`,
      "Accept-Ranges": "bytes",
      "Content-Length": chunkSize,
      "Content-Type": "video/mp4",
    });

    fileStream.pipe(res);
  } else {
    res.writeHead(200, {
      "Content-Length": fileSize,
      "Content-Type": "video/mp4",
    });

    fs.createReadStream(videoFilePath).pipe(res);
  }

  /*
  
    // Set the content type header
    res.setHeader('Accept-Ranges', 'bytes');
  
  
   
  
   
    // Stream the video file
    console.log("\n\n\n\n\n\n\n"+req.url+"\n\n\n\n\n")
    const videoStream = fs.createReadStream(videoFilePath);
    videoStream.pipe(res); */
});

async function fetchData(files) {
  var names = [];
  for (var i = 0; i < files.length; i++) {
    //console.error(ele);

    await axios
      .get(
        "https://www.omdbapi.com/?apikey=5e86429e&t=" + files[i].split(".")[0]
      )
      .then((response) => {
        //  console.log('Status Code:', response.status);
        // console.log('Response:', response.data);
        var data = response.data;
        data["Link"] = "http://"+IP+":3000/showMovie?name=" + files[i].replaceAll(" ","$");
        names.push(response.data);
      })
      .catch((error) => {
        console.error("Error:", error);
      });
  }

  return names;
}

app.get("/movies", (req, res) => {

  //  console.log("my ip"+req.ip.split(":")[3])
  // const videoFilePath = path.resolve(__dirname, videoPath);
  new Promise((resolve, reject) => {
    dns.reverse(req.ip.split(":")[3], (err, hostnames) => {
      if (err) {
        reject(err);
      } else {
        if (hostnames && hostnames.length > 0) {
          resolve(hostnames[0]); // Returns the primary hostname associated with the IP address
          console.log("Connectedclients:"+hostnames[0]);
        } else {
          resolve(null); // No hostname found for the given IP address
        }
      }
    });
  });
    console.log(MovieDirectory)
  


  fs.readdir(MovieDirectory, async (err, movies) => {

    

    var names = await fetchData(movies);

    var dataToSend=[]

    names.forEach((e)=>{

      console.log(names)
      if(req.query.type.includes(e['Type'])&& e['Genre'].includes(req.query.genre))
      {
        
        dataToSend.push(e)
      }
   
    })




    console.log(dataToSend)
    res.json(dataToSend);

    if (err) {
      console.error("Error reading directory:", err);

      return;
    }

 




    // console.log('Files in the directory:', JSON.stringify([...names]));
  });

  // Stream the video file
  //const videoStream = fs.createReadStream(videoFilePath);
  // videoStream.pipe(res);
});



app.get("/series", (req, res) => {
  // const videoFilePath = path.resolve(__dirname, videoPath);

  //path fo series
  var baseLocation = MovieDirectory + req.query.t + "/";
  console.log(baseLocation);

  fs.readdir(baseLocation, async (err, files) => {
    const seasonFolders = files.filter((file) =>
      fs.statSync(`${baseLocation}${file}`).isDirectory()
    );

   

   const data = await Promise.all(seasonFolders.map(async (season) => {
      const episodes = await fs.promises.readdir(baseLocation + season + "/");
      const links = episodes.map((episode) => ({
        episodeName: episode,
        link: "http://"+IP+":3000/showSeries/"+req.query.t.replaceAll(" ","$")+"/"+season.replaceAll(" ","$")+"/"+episode.replaceAll(" ","$")
      }));
      return links;
    }));
    console.log(data);
    res.json(data);



    if (err) {
      console.error("Error reading directory:", err);

      return;
    }
  });

  // Stream the video file
  //const videoStream = fs.createReadStream(videoFilePath);
  // videoStream.pipe(res);
});


app.get("/clients",(req,res)=>{

  const userAgent = req.headers['user-agent'];
  res.write(userAgent);



})
const PORT = 3000;
app.listen(PORT,() => {
  console.log(`Server is listening on port ${PORT}`);


});
