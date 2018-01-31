/**
 * job2. Break the sales down by product category across all of stores
 * job3. Find the monetary value for the highest individual sale for each separate store
 * job4. Find the total sales value across all the stores, and the total number of sales 
 *       (Assume there is only one reducer)
 */

import java.lang.String;
import java.text.SimpleDateFormat;
import java.util.Date; 
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
import org.apache.hadoop.io.DoubleWritable; 
import org.apache.hadoop.util.GenericOptionsParser; 
 
public class SalesAnalyzer {

    public static class CostByItemMapper 
         extends Mapper<Object, Text, Text, DoubleWritable>{
        
        public void map(Object key, Text value, Context context
                        ) throws IOException, InterruptedException {
            Text           keyText   = new Text();
            DoubleWritable valDouble = new DoubleWritable();
            SalesRecord    record    = new SalesRecord();
            String[] lines = value.toString().split("\n");
            for (int ii=0; ii<lines.length; ii+=1) {
                if( record.readLine(lines[ii]) ) {
                    keyText.set(record.getItemName()); 
                    valDouble.set(record.getRetail()); 
                    context.write(keyText, valDouble); 
                }
            }
        }
    }

    public static class CostByStoreMapper 
         extends Mapper<Object, Text, Text, DoubleWritable>{
        
        public void map(Object key, Text value, Context context
                        ) throws IOException, InterruptedException {
            Text           keyText   = new Text();
            DoubleWritable valDouble = new DoubleWritable(); 
            SalesRecord    record    = new SalesRecord(); 
            String[]       lines     = value.toString().split("\n");
            for (int ii=0; ii<lines.length; ii+=1) {
                if( record.readLine(lines[ii]) ) {
                    keyText.set(record.getStoreName()); 
                    valDouble.set(record.getRetail()); 
                    context.write(keyText, valDouble); 
                }
            }
        }
    }

    public static class ValueAndNumberMapper 
         extends Mapper<Object, Text, Text, DoubleWritable>{
        
        private final Text           ValueText  = new Text("Value");
        private final Text           NumberText = new Text("Number"); 
        private final DoubleWritable ONE        = new DoubleWritable(1.00);
        
        public void map(Object key, Text value, Context context
                        ) throws IOException, InterruptedException {
            DoubleWritable valDouble = new DoubleWritable();
            SalesRecord    record    = new SalesRecord(); 
            String[]       lines     = value.toString().split("\n");
            for (int ii=0; ii<lines.length; ii+=1) {
                if( record.readLine(lines[ii]) ) {
                    valDouble.set(record.getRetail());
                    context.write(ValueText, valDouble); 
                    context.write(NumberText, ONE); 
                }
            }
        }
    }

    public static class DoubleSumReducer 
         extends Reducer<Text, DoubleWritable, Text, DoubleWritable>{
        
        private DoubleWritable result = new DoubleWritable();
        
        public void reduce(Text key, Iterable<DoubleWritable> values, Context context) 
             throws IOException, InterruptedException {
            double sum = 0; 
            for (DoubleWritable val : values){
                sum += val.get(); 
            }
            result.set(sum); 
            context.write(key, result); 
        }
    }

    public static class DoubleSumTextReducer 
         extends Reducer<Text, DoubleWritable, Text, Text>{
        
        private Text result = new Text();
        
        public void reduce(Text key, Iterable<DoubleWritable> values, Context context) 
             throws IOException, InterruptedException {
            double sum = 0; 
            for (DoubleWritable val : values){
                sum += val.get(); 
            }
            result.set(String.format("%.2f", sum)); 
            context.write(key, result); 
        }
    }

    public static class DoubleMaxReducer 
         extends Reducer<Text, DoubleWritable, Text, DoubleWritable>{
        
        private DoubleWritable result = new DoubleWritable();
        
        public void reduce(Text key, Iterable<DoubleWritable> values, Context context) 
             throws IOException, InterruptedException {
            double max = -Double.MAX_VALUE; 
            double value; 
            for (DoubleWritable val : values){
                value = val.get(); 
                if (value>max) {
                    max = value; 
                }
            }
            result.set(max); 
            context.write(key, result); 
        }
    }

    public static class DoubleMaxTextReducer 
         extends Reducer<Text, DoubleWritable, Text, Text>{
        
        private Text result = new Text();
        
        public void reduce(Text key, Iterable<DoubleWritable> values, Context context) 
             throws IOException, InterruptedException {
            double max = -Double.MAX_VALUE; 
            double value; 
            for (DoubleWritable val : values){
                value = val.get(); 
                if (value>max) {
                    max = value; 
                }
            }
            result.set(String.format("%.2f", max)); 
            context.write(key, result); 
        }
    }
    
    private static boolean job02runner(Configuration conf, String[] args) throws Exception {
        Job job = Job.getInstance(conf, "Analyzer: Sum of Cost by Item");
        job.setJarByClass(SalesAnalyzer.class); 
        job.setMapperClass(CostByItemMapper.class); 
        job.setCombinerClass(DoubleSumReducer.class); 
        job.setReducerClass(DoubleSumTextReducer.class);
        job.setOutputKeyClass(Text.class);                // LongWritable by default
        job.setMapOutputValueClass(DoubleWritable.class); // Text by default
        for (int ii = 0; ii < args.length - 1; ii+=1) {
            FileInputFormat.addInputPath(job, new Path(args[ii]));
        }
        FileOutputFormat.setOutputPath(job, 
            new Path(args[args.length - 1].concat("/SumCostByItem"))
        );
        return job.waitForCompletion(true); 
    }

    private static boolean job03runner(Configuration conf, String[] args) throws Exception {
        Job job = Job.getInstance(conf, "Analyzer: Maximum Cost by Store");
        job.setJarByClass(SalesAnalyzer.class); 
        job.setMapperClass(CostByStoreMapper.class); 
        job.setCombinerClass(DoubleMaxReducer.class); 
        job.setReducerClass(DoubleMaxTextReducer.class);
        job.setOutputKeyClass(Text.class);                // LongWritable by default
        job.setMapOutputValueClass(DoubleWritable.class); // Text by default
        for (int ii = 0; ii < args.length - 1; ii+=1) {
            FileInputFormat.addInputPath(job, new Path(args[ii]));
        }
        FileOutputFormat.setOutputPath(job, 
            new Path(args[args.length - 1].concat("/MaxCostByStore"))
        );
        return job.waitForCompletion(true); 
    }

    private static boolean job04runner(Configuration conf, String[] args) throws Exception {
        Job job = Job.getInstance(conf, "Analyzer: Total Value and Total Number");
        job.setJarByClass(SalesAnalyzer.class); 
        job.setMapperClass(ValueAndNumberMapper.class); 
        job.setCombinerClass(DoubleSumReducer.class); 
        job.setReducerClass(DoubleSumTextReducer.class);
        job.setOutputKeyClass(Text.class);                // LongWritable by default
        job.setMapOutputValueClass(DoubleWritable.class); // Text by default
        for (int ii = 0; ii < args.length - 1; ii+=1) {
            FileInputFormat.addInputPath(job, new Path(args[ii]));
        }
        FileOutputFormat.setOutputPath(job, 
            new Path(args[args.length - 1].concat("/Total"))
        );
        return job.waitForCompletion(true); 
    }

    public static void main(String[] args) throws Exception {
        Configuration conf = new Configuration(); 
        String[] otherArgs = new GenericOptionsParser(conf, args).getRemainingArgs(); 
        if (otherArgs.length < 2) {
            System.err.println("Usage: SalesAnalyzer <in> [<in>...] <out>");
            System.exit(2);
        }
        boolean res = true;
        res = res && job02runner(conf, otherArgs); 
        res = res && job03runner(conf, otherArgs); 
        res = res && job04runner(conf, otherArgs); 
        System.exit(res ? 0 : 1); 
    }
}
 
class SalesRecord {

	private final static SimpleDateFormat dateFormat1 = new SimpleDateFormat("yyyy-MM-dd");
	private final static SimpleDateFormat dateFormat2 = new SimpleDateFormat("yyyy-MM-dd H:mm"); 
	private boolean  success;
	private String[] fields;  
	private String   dataText; 
	private String   timeText; 
	private Date     data;
	private String   storeText; 
	private String   itemText; 
	private String   costText;
	private double   cost; 
	private String   paymentText; 

	public boolean readLine(String line) {
		boolean success = false; 
		fields = line.split("\t"); 
		long length = fields.length; 
		if ( length <=0 ) {
			return success; 
		} else {
			if ( length == 6 ) {
				success = true; 
			}
			try {
				dataText    = fields[0]; 
				try { 
					data = dateFormat1.parse(dataText);
				} catch (ParseException e) {
					data = null; 
					success = false; 
				}
				timeText    = fields[1]; 
				try { 
					data = dateFormat1.parse(
						dataText.concat(" ").concat(timeText)
					);
				} catch (ParseException e) {
					data = null; 
					success = false; 
				}
				storeText   = fields[2];
				itemText    = fields[3];
				costText    = fields[4]; 
				try {
					cost = Double.parseDouble(costText);
				} catch (NumberFormatException e) {
					cost = 0.0; 
					success = false; 
				}
				paymentText = fields[5];
			} catch (ArrayIndexOutOfBoundsException e) {
				success = false; 
			} finally {
				return success; 
			}
		}
	} 
	
	public boolean isSuccess() {
	    return success; 
	}
	
	public String getItemName() {
	    return itemText;
	}
	
	public String getStoreName() {
	    return storeText; 
	}
	
	public double getRetail() {
	    return cost;
	}
}
