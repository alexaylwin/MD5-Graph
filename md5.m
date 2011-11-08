function digest = md5(message)
 
%% Helper Function Definitions
 
    %This function converts a binary representation of a number or vector
    %of numbers from a string to a row vector of 1's and 0's
    function matrix = binStr2mat(binStr)
        matrix = zeros(size(binStr));
        for n = (1:numel(binStr))
            matrix(n) = str2double(binStr(n));
        end
    end
 
    %This acts as a "lower <= x <= upper" operator
    function trueFalse = inRange(lowerBound,theValue,upperBound)
        trueFalse = (lowerBound <= theValue) && (theValue <= upperBound);
    end
 
    %This converts a decimal number into its 32-bit binary representation,
    %and I'm pretty sure it is little-endian
    function binaryRep = to32BitBin(decimal)
        binaryRep = binStr2mat(dec2bin(decimal,32));
    end
 
    %This converts a decimal number into its 64-bit binary representation,
    %and I'm pretty sure it is little-endian
    function binaryRep = to64BitBin(decimal)
        binaryRep = binStr2mat(dec2bin(decimal,64));
    end
 
    %This adds multiple binary numbers together modulo 2^32. The sum of these
    %numbers will rap around if the sum of two numbers is >= 2^32
    function result = addBinary(varargin)      
        result = 0;        
        for l = (1:numel(varargin))
            temp = num2str(varargin{l});
            temp(temp == ' ') = [];
            result = mod(result + bin2dec(temp),2^32);
        end
        result = to32BitBin(result);
    end
 
%% MD5 Hash Algorithm
 
%Define constants
    %r is the bit-shift amount for each round
    r =[7,12,17,22,7,12,17,22,7,12,17,22,7,12,17,22,5,9,14,20,5,9,14,20,5,...
        9,14,20,5,9,14,20,4,11,16,23,4,11,16,23,4,11,16,23,4,11,16,23,...
        6,10,15,21,6,10,15,21,6,10,15,21,6,10,15,21];
 
    %Use the binary representation of the radian values of sine represented
    %as 32-bit integers
    k = to32BitBin(floor(abs(sin(1:64).*(2^32))));
 
%Initialize the hash variables, convert the hex representation of these
    %variables to their 32-bit binary representation
    h0 = to32BitBin(hex2dec('67452301'));
    h1 = to32BitBin(hex2dec('EFCDAB89'));
	h2 = to32BitBin(hex2dec('98BADCFE'));
	h3 = to32BitBin(hex2dec('10325476'));
 
    %Convert the ASCII values of the input string to a  binary string matrix
    message = dec2bin(message);
    N = numel(message);
 
    %Convert the message matrix to one long bit stream
    message = reshape(transpose(message),1,N);
 
    %Perform the pre-prossesing of appending a 1-bit to the message, then
    %enough zeros to make the length of the message congruent to 448 mod
    %512. Then append the 64-bit representation of the length of the
    %original message string to the end.
    message = [binStr2mat([message '1']) zeros(1,abs(mod(N+1,512) - 448)) to64BitBin(N)];
 
%Process 512-bit chunks of the pre-processed message string
    for chunk = (1:(numel(message)/512))
 
        %Stored the index of the first bit in the chunk
        blockIndex = ((chunk-1)*512)+1;
 
        %Pull out the 512-bit chunk from the message, then reshape it into
        %32, 16-bit strings. Then transpose that string matrix to recover 16,
        %32-bit words in the correct order. If we do this directly, by
        %reshaping the 512-bit chunk to 16, 32-bit strings the original
        %order of the bits will be scrambled.
        w = transpose(reshape(message(blockIndex:blockIndex+511),32,16));
 
        %Initialize the hashes for this round
        a = h0;
        b = h1;
        c = h2;
        d = h3;
 
        %Process the hahes
        %Note: The original MD5 algorithm pseudo-code was written for
        %0-based arrays. Therefore, the calculation for "g" has been
        %modified for MATLAB's 1-based arrays
        for i = (1:64)
            if inRange(1,i,16)
                f = (b & c) | ((~b) & d);
                g = i;
            elseif inRange(17,i,32)
                f = (d & b) | ((~d) & c);
                g = mod( (5*(i-1)) + 1 ,16) + 1;
            elseif inRange(33,i,48)
                f = xor( b,xor(c,d) );
                g = mod( (3*(i-1)) + 5 ,16) + 1; 
            elseif inRange(48,i,64)
                f = xor( c, (b | (~d)) );
                g = mod( (7*(i-1)),16 ) + 1;
            end
 
            temp = d;
            d = c;
            c = b;
 
            %The circshift has a -r(i) because normally this function
            %rotates right, not left.
            b = addBinary(b,circshift( addBinary(a,f,k(i,1:32),w(g,1:32)),[0 -r(i)] ));
            a = temp;
 
        end
 
        %Add this chunk's hash to all the previous chunks' hashes
        h0 = addBinary(h0,a);
        h1 = addBinary(h1,b);
        h2 = addBinary(h2,c);
        h3 = addBinary(h3,d);
 
    end
 
    %Concatenate the hashes together and convert them to a binary string
    digest = num2str([h0 h1 h2 h3]);
 
    %Remove whitespace from the digest, leaving 1's and 0's
    digest(digest == ' ') = [];
 
    %Convert the binary representation of the digest to a hexadecimal
    digest = lower(bin2hex(digest));
 
end %md5