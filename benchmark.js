let fps = [];
let interval;
let timeout;

const getFps = function()
{
	return parseFloat(document.getElementById("myFramerate").innerText.split(" ")[0]);
};

const addFps = function(n)
{
	fps.push(n);
};

const getFpsAverage = function()
{
	let total = 0.;

	for(let e of fps)
	{
		total += e;
	}

	total /= fps.length;

	return total;
};

const addCurrentFps = function()
{
	addFps(getFps());
};

const test = async function(test_length_s, interval_ms)
{
	fps = [];

	console.log("test start");

	interval = setInterval(addCurrentFps, interval_ms);

	timeout = setTimeout(() =>
	{
		clearInterval(interval);

		console.log("test done");
		console.log("\n\n----------------");
		console.log("Total Samples: " + fps.length);
		console.log("Average Fps: " + getFpsAverage());
		console.log("--------------------");
	}, test_length_s * 1000);
};

let run = function() {test(30, 100);};

setTimeout(run, 10000);
