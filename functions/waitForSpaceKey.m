function waitForSpaceKey()

keyIsDown = true;
while keyIsDown
	[keyIsDown, t00, keyCode, deltaSecs] = KbCheck();
end
done = false;
while ~done
	[keyIsDown, secs, keyCode, deltaSecs] = KbCheck();
	done = keyCode(KbName('Space'));
end
