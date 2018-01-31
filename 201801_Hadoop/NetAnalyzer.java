/**
 * job6. Number of requests for each file on the Web site
 * job7. Number of requests to the site made by each IP address
 * job8. Most popular file on the website (sort job6)
 */

import java.lang.String;
import java.text.SimpleDateFormat;
import java.util.Date; 
import java.util.regex.Pattern; 
import java.util.regex.Matcher;
import java.io.IOException;
import java.text.ParseException; 
import java.lang.ArrayIndexOutOfBoundsException; 
 
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.conf.Configuration; 
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.LongWritable; 
import org.apache.hadoop.util.GenericOptionsParser; 
import org.apache.hadoop.mapreduce.lib.map.InverseMapper; 
import org.apache.hadoop.mapreduce.lib.reduce.LongSumReducer;
import org.apache.hadoop.mapreduce.lib.input.SequenceFileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.SequenceFileOutputFormat; 
 
public class NetAnalyzer {

    public static class HitByFileMapper 
         extends Mapper<Object, Text, Text, LongWritable>{
        
        private final static LongWritable ONE = new LongWritable(1);
        
        public void map(Object key, Text value, Context context
                        ) throws IOException, InterruptedException {
            Text keyText        = new Text();
            String[] lines      = value.toString().split("\n");
            CommonLogFormat clf = new CommonLogFormat();
            for (int ii=0; ii<lines.length; ii+=1) {
                if( clf.readLine(lines[ii]) ) {
                    keyText.set(clf.getResourcePath()); 
                    context.write(keyText, ONE); 
                }
            }
        }
    }

    public static class HitByAddressMapper 
         extends Mapper<Object, Text, Text, LongWritable>{
        
        private final static LongWritable ONE = new LongWritable(1);
        
        public void map(Object key, Text value, Context context
                        ) throws IOException, InterruptedException {
            Text keyText        = new Text();
            String[] lines      = value.toString().split("\n");
            CommonLogFormat clf = new CommonLogFormat();
            for (int ii=0; ii<lines.length; ii+=1) {
                if( clf.readLine(lines[ii]) ) {
                    keyText.set(clf.getAddress()); 
                    context.write(keyText, ONE); 
                }
            }
        }
    }

    private static boolean job05runner(Configuration conf, String[] args) throws Exception {
        Job job = Job.getInstance(conf, "Analyzer: Number of Hits by Resource");
        job.setJarByClass(NetAnalyzer.class); 
        job.setMapperClass(HitByFileMapper.class); 
        job.setCombinerClass(LongSumReducer.class); 
        job.setReducerClass(LongSumReducer.class);
        job.setOutputKeyClass(Text.class);             // LongWritable by default
        job.setOutputValueClass(LongWritable.class);   // Text by default
        for (int ii = 0; ii < args.length - 1; ii+=1) {
            FileInputFormat.addInputPath(job, new Path(args[ii]));
        }
        Path tempDir = new Path(args[args.length - 1].concat("/SumHitByFile")); 
        FileOutputFormat.setOutputPath(job, tempDir);
        return job.waitForCompletion(true);
    }

    private static boolean job06runner(Configuration conf, String[] args) throws Exception {
        Job job = Job.getInstance(conf, "Analyzer: Number of Hits by Client Address");
        job.setJarByClass(NetAnalyzer.class); 
        job.setMapperClass(HitByAddressMapper.class); 
        job.setCombinerClass(LongSumReducer.class); 
        job.setReducerClass(LongSumReducer.class);
        job.setOutputKeyClass(Text.class);           // LongWritable by default
        job.setOutputValueClass(LongWritable.class); // Text by default
        for (int ii = 0; ii < args.length - 1; ii+=1) {
            FileInputFormat.addInputPath(job, new Path(args[ii]));
        }
        FileOutputFormat.setOutputPath(job, 
            new Path(args[args.length - 1].concat("/SumHitByAddress"))
        );
        return job.waitForCompletion(true); 
    }

    private static boolean job07runner(Configuration conf, String[] args) throws Exception {
        Job job = Job.getInstance(conf, "Analyzer: Number of Hits by Resource");
        job.setJarByClass(NetAnalyzer.class); 
        job.setMapperClass(HitByFileMapper.class); 
        job.setCombinerClass(LongSumReducer.class); 
        job.setReducerClass(LongSumReducer.class);
        job.setOutputKeyClass(Text.class);           // LongWritable by default
        job.setOutputValueClass(LongWritable.class); // Text by default
        for (int ii = 0; ii < args.length - 1; ii+=1) {
            FileInputFormat.addInputPath(job, new Path(args[ii]));
        }
        Path tempDir   = new Path(args[args.length - 1].concat("/SumHitByFile_"));
        Path outputDir = new Path(args[args.length - 1].concat("/SortedHitByFile"));
        FileOutputFormat.setOutputPath(job, tempDir);
        job.setOutputFormatClass(SequenceFileOutputFormat.class);
        if(!job.waitForCompletion(true)){
            return false; 
        }
        Job sortJob = Job.getInstance(conf, "Analyzer: Sorting");
        sortJob.setJarByClass(NetAnalyzer.class); 
        FileInputFormat.setInputPaths(sortJob, tempDir);
        sortJob.setInputFormatClass(SequenceFileInputFormat.class); 
        sortJob.setMapperClass(InverseMapper.class);
        FileOutputFormat.setOutputPath(sortJob, outputDir);
        sortJob.setSortComparatorClass(LongWritable.DecreasingComparator.class);
        return sortJob.waitForCompletion(true);
    }

    public static void main(String[] args) throws Exception {
        Configuration conf = new Configuration(); 
        String[] otherArgs = new GenericOptionsParser(conf, args).getRemainingArgs(); 
        if (otherArgs.length < 2) {
            System.err.println("Usage: NetAnalyzer <in> [<in>...] <out>");
            System.exit(2);
        }
        boolean res = true;
        res = res && job05runner(conf, otherArgs); 
        res = res && job06runner(conf, otherArgs);
        res = res && job07runner(conf, otherArgs);
        System.exit(res ? 0 : 1); 
    }
}
 
class CommonLogFormat {
    
    private final   Pattern          pattern_CLF = Pattern.compile("^(\\S+) (\\S+) (\\S+) \\[(\\S+\\s\\S+)\\] \"([^\"]*)\" (\\S+) (\\S+)$");
    private final   Pattern          pattern_IP  = Pattern.compile("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$");
    private final   SimpleDateFormat dateFormat  = new SimpleDateFormat("dd/MMM/yyyy:HH:mm:ss Z");
    private final   Pattern          pattern_req = Pattern.compile("^(\\S+)\\s+(\\S+)\\s+(\\S+)$");
    private final   String           domain      = "the-associates.co.uk"; 
    private final   String           domainRegex = "^" + Pattern.quote("http://") + "(" + Pattern.quote("www.") + ")?" + Pattern.quote(domain); 
    private boolean success; 
    private String  rawLine;
    private String  addressText;
    private String  userId;
    private String  userName;
    private String  datetimeText;
    private Date    datetime;
    private String  requestText; 
    private String  requestText_method; 
    private String  requestText_resourcePath;
    private String  requestText_protocol; 
    private String  statusText;
    private String  sizeText; 
    
    public boolean readLine(String line) {
        success = false; 
        rawLine = line; 
        addressText = userId = userName = datetimeText = 
        requestText = requestText_method = requestText_resourcePath = requestText_protocol =
        statusText = sizeText = null; 
        datetime = null; 
        Matcher matcherLine = pattern_CLF.matcher(line);
        if (!matcherLine.matches()) {
            return success; 
        } 
        success = true; 
        addressText  = matcherLine.group(1); 
        if (!pattern_IP.matcher(addressText).matches()) {
            success = false; 
        }
        userId       = matcherLine.group(2); 
        userName     = matcherLine.group(3); 
        datetimeText = matcherLine.group(4); 
        try {
            datetime = dateFormat.parse(datetimeText); 
        } catch (ParseException e) {
            datetime = null; 
            success  = false; 
        }
        requestText  = matcherLine.group(5); 
        Matcher matcherRequest = pattern_req.matcher(requestText);
        if (!matcherRequest.matches()) {
            success = false; 
        } else {
            requestText_method       = matcherRequest.group(1); 
            requestText_resourcePath = matcherRequest.group(2); 
            requestText_resourcePath = requestText_resourcePath.replaceFirst(domainRegex, "");
            requestText_protocol     = matcherRequest.group(3); 
        }
        statusText   = matcherLine.group(6); 
        sizeText     = matcherLine.group(7); 
        return success; 
    }
    
    public String getResourcePath() {
        return requestText_resourcePath; 
    }
    
    public String getAddress() {
        return addressText;
    }
}
 