setTimeout(() => startRecording(), 20000);

function startRecording() {
  console.log('start recording')
  var canvas = document.getElementById('canvas')
  const chunks = []; // here we will store our recorded media chunks (Blobs)
  const stream = canvas.captureStream(); // grab our canvas MediaStream
  const rec = new MediaRecorder(stream); // init the recorder
  // every time the recorder has new data, we will store it in our array
  rec.ondataavailable = e => chunks.push(e.data);
  // only when the recorder stops, we construct a complete Blob from all the chunks
  rec.onstop = e => exportVid(new Blob(chunks, {type: 'video/webm'}));
  
  rec.start();
  setTimeout(()=>rec.stop(), 2 * 3.1415 * 1000); // stop recording in 3s
}

function exportVid(blob) {
  console.log('stop recording')
  const vid = document.createElement('video');
  vid.src = URL.createObjectURL(blob);
  vid.controls = true;
  document.body.appendChild(vid);
  const a = document.createElement('a');
  a.download = 'step10.webm';
  a.href = vid.src;
  a.textContent = 'Download recording';
  //a.className = 'movie-link'
  a.style = 'position: fixed; left: 10px; top: 10px; color: #454525; text-decoration: none;'
  document.body.appendChild(a);
}
