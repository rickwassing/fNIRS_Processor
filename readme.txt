FNIRS Processor


In the Homer3 package, add the following line to the function hmrR_GLM.m prior to the final 'end' statement (line 840).
>> hmrstats.desmat = At;