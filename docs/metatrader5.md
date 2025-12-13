### OpenCL Program Creation Example

Source: https://www.mql5.com/en/docs/opencl/clprogramcreate

Demonstrates the creation of an OpenCL program using the CLProgramCreate function within an MQL5 script. It includes necessary setup like context creation and error handling. The example also shows how to define OpenCL kernel source code and handle potential compilation issues, such as enabling double-precision floating-point support.

```MQL5
//+------------------------------------------------------------------+
//| OpenCL kernel |
//+------------------------------------------------------------------+
const string
cl_src=
//--- by default some GPU doesn't support doubles
//--- cl_khr_fp64 directive is used to enable work with doubles
"#pragma OPENCL EXTENSION cl_khr_fp64 : enable \r\n"
//--- OpenCL kernel function
"__kernel void Test_GPU(__global double *data, \r\n"
" const int N, \r\n"
" const int total_arrays) \r\n"
" { \r\n"
" uint kernel_index=get_global_id(0); \r\n"
" if (kernel_index>total_arrays) return; \r\n"
" uint local_start_offset=kernel_index*N; \r\n"
" for(int i=0; i<N; i++) \r\n"
" { \r\n"
" data[i+local_start_offset] *= 2.0; \r\n"
" } \r\n"
" } \r\n";

//+------------------------------------------------------------------+
//| Script program start function |
//+------------------------------------------------------------------+
int OnStart()
{
//--- initialize OpenCL objects
//--- create OpenCL context
if((cl_ctx=CLContextCreate())==INVALID_HANDLE)
{
Print("OpenCL not found. Error=",GetLastError());
return(1);
}
//--- create OpenCL program
if((cl_prg=CLProgramCreate(cl_ctx,cl_src))==INVALID_HANDLE)
{
CLContextFree(cl_ctx);
Print("OpenCL program create failed. Error=",GetLastError());
return(1);
}
//--- create OpenCL kernel
if((cl_krn=CLKernelCreate(cl_prg,"Test_GPU"))==INVALID_HANDLE)
{
CLProgramFree(cl_prg);
CLContextFree(cl_ctx);
Print("OpenCL kernel create failed. Error=",GetLastError());
return(1);
}
//--- create OpenCL buffer
if((cl_mem=CLBufferCreate(cl_ctx,ARRAY_SIZE*TOTAL_ARRAYS*sizeof(double),CL_MEM_READ_WRITE))==INVALID_HANDLE)
{
CLKernelFree(cl_krn);
CLProgramFree(cl_prg);
CLContextFree(cl_ctx);
Print("OpenCL buffer create failed. Error=",GetLastError());
return(1);
}
//--- set OpenCL kernel constant parameters
CLSetKernelArgMem(cl_krn,0,cl_mem);
CLSetKernelArg(cl_krn,1,ARRAY_SIZE);
CLSetKernelArg(cl_krn,2,TOTAL_ARRAYS);
//--- prepare data arrays
ArrayResize(DataArray1,ARRAY_SIZE*TOTAL_ARRAYS);
ArrayResize(DataArray2,ARRAY_SIZE*TOTAL_ARRAYS);
//--- fill arrays with data
for(int j=0; j<TOTAL_ARRAYS; j++)
{
//--- calculate local start offset for jth array
uint local_offset=j*ARRAY_SIZE;
//--- prepare array with index j

```

--------------------------------

### Initialize MQL5 Connection and Get Version with Python

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5shutdown_py

Establishes a connection to the MetaTrader 5 terminal and retrieves package information such as author and version. It also displays terminal information and the MetaTrader 5 version. Requires the MetaTrader5 library to be installed.

```python
import MetaTrader5 as mt5

# display data on the MetaTrader 5 package
print("MetaTrader5 package author: ", mt5.__author__)
print("MetaTrader5 package version: ", mt5.__version__)

# establish connection to the MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed")
    quit()

# display data on connection status, server name and trading account
print(mt5.terminal_info())
# display data on MetaTrader 5 version
print(mt5.version())

# shut down connection to the MetaTrader 5 terminal
mt5.shutdown()
```

--------------------------------

### MQL5 Start Event Handler: OnStart Function

Source: https://www.mql5.com/en/docs/basis/function/events

The OnStart() function is the event handler for the Start event, automatically generated for running scripts. It must have a void return type and no parameters. An integer return type can also be specified.

```MQL5
void OnStart();
```

--------------------------------

### MQL5 Structure Inheritance and Copying Example

Source: https://www.mql5.com/en/docs/basis/types/classes

Demonstrates MQL5 structure inheritance with 'Animal', 'Dog', and 'Cat' structures. It shows how to create objects, copy data between ancestor and descendant structures, and highlights limitations in copying between sibling structures. Includes an example of creating an array of structures and printing its contents.

```MQL5
bool hunting;
};

//--- structure for describing cats
struct Cat: Animal
{
bool home; // home breed
};

//+------------------------------------------------------------------+
//| Script program start function |
//+------------------------------------------------------------------+
void OnStart()
{
//--- create and describe an object of the basic Animal type
Animal some_animal;
some_animal.head=1;
some_animal.legs=4;
some_animal.wings=0;
some_animal.tail=true;
some_animal.fly=false;
some_animal.swim=false;
some_animal.run=true;

//--- create objects of child types
Dog dog;
Cat cat;

//--- can be copied from ancestor to descendant (Animal ==> Dog)
dog=some_animal;
dog.swim=true; // dogs can swim

//--- you cannot copy objects of child structures (Dog != Cat)
//cat=dog; // compiler returns an error here

//--- therefore, it is possible to copy elements one by one only
cat.head=dog.head;
cat.legs=dog.legs;
cat.wings=dog.wings;
cat.tail=dog.tail;
cat.fly=dog.fly;
cat.swim=false; // cats cannot swim

//--- it is possible to copy the values from descendant to ancestor
Animal elephant;
elephant=cat;
elephant.run=false;// elephants cannot run
elephant.swim=true;// elephants can swim

//--- create an array
Animal animals[4];
animals[0]=some_animal;
animals[1]=dog;
animals[2]=cat;
animals[3]=elephant;

//--- print out
ArrayPrint(animals);

//--- execution result
/*
[head] [legs] [wings] [tail] [fly] [swim] [run]
[0] 1 4 0 true false false true
[1] 1 4 0 true false true true
[2] 1 4 0 true false false false
[3] 1 4 0 true false true false
*/
}
```

--------------------------------

### MQL5 Custom Indicator Initialization Example

Source: https://www.mql5.com/en/docs/customind

This snippet demonstrates the basic structure of a custom indicator's initialization function (OnInit) in MQL5. It includes setting up indicator properties and mapping data buffers.

```MQL5
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 1

//---- plot Label1
#property indicator_label1 "Label1"
#property indicator_type1 DRAW_LINE
#property indicator_color1 clrRed
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1

//--- indicator buffers
double Label1Buffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
void OnInit()
{
//--- indicator buffers mapping
SetIndexBuffer(0, Label1Buffer, INDICATOR_DATA);
//--- 
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])

{
//--- 
Print("begin = ",begin," prev_calculated = ",prev_calculated," rates_total = ",rates_total);
//--- return value of prev_calculated for next call
return(rates_total);
}
```

--------------------------------

### OpenCL Pi Calculation Example

Source: https://www.mql5.com/en/docs/opencl/clbufferread

An example demonstrating OpenCL usage in MQL5 for calculating Pi. It includes OpenCL kernel source code and MQL5 code for context creation, program compilation, and kernel execution.

```MQL5
#define _num_steps 1000000000
#define _divisor 40000
#define _step 1.0 / _num_steps
#define _intrnCnt _num_steps / _divisor

//+------------------------------------------------------------------+
//| |   
//+------------------------------------------------------------------+
string D2S(double arg, int digits) { return DoubleToString(arg, digits); }
string I2S(int arg) { return IntegerToString(arg); }

//--- OpenCL programm code
const string clSource=
"#define _step "+D2S(_step, 12)+" \r\n"
+"#define _intrnCnt "+I2S(_intrnCnt)+" \r\n"
+" \r\n"
+"__kernel void Pi( __global double *out ) \r\n"
+"{ \r\n"
+" int i = get_global_id( 0 ); \r\n"
+" double partsum = 0.0; \r\n"
+" double x = 0.0; \r\n"
+" long from = i * _intrnCnt; \r\n"
+" long to = from + _intrnCnt; \r\n"
+" for( long j = from; j < to; j ++ ) \r\n"
+" { \r\n"
+" x = ( j + 0.5 ) * _step; \r\n"
+" partsum += 4.0 / ( 1. + x * x ); \r\n"
+" } \r\n"
+" out[ i ] = partsum; \r\n"
+"} \r\n";

//+------------------------------------------------------------------+
//| Script program start function |
//+------------------------------------------------------------------+
int OnStart()
{
Print("Pi Calculation: step = "+D2S(_step, 12)+"; _intrnCnt = "+I2S(_intrnCnt));
//--- prepare OpenCL contexts
int clCtx;
if((clCtx=CLContextCreate(CL_USE_GPU_ONLY))==INVALID_HANDLE)
{
Print("OpenCL not found");
return(-1);
}
int clPrg = CLProgramCreate(clCtx, clSource);
int clKrn = CLKernelCreate(clPrg, "Pi");

```

--------------------------------

### Example SQL Query for Counting Records

Source: https://www.mql5.com/en/docs/database

A basic SQL query example demonstrating how to count all records within a table, aliasing the result as 'book_count'. This is a foundational query often used for data summarization.

```SQL
select   
count(*) as book_count,   
```

--------------------------------

### MQL5: Place a Pending Order

Source: https://www.mql5.com/en/docs/constants/structures/mqltraderequest

This MQL5 code snippet illustrates the setup for placing a pending order. It defines a magic number, includes input parameters for the order type, and shows how to initialize the MqlTradeRequest structure. The code is a starting point and would typically be expanded to include volume, price, SL/TP, and other required fields for a complete order placement.

```mql5
#property description "Example of placing pending orders"
#property script_show_inputs
#define EXPERT_MAGIC 123456 // MagicNumber of the expert
input ENUM_ORDER_TYPE orderType=ORDER_TYPE_BUY_LIMIT; // order type

```

--------------------------------

### MQL5 to DLL Matrix/Vector Passing Example

Source: https://www.mql5.com/en/docs/matrix

Demonstrates how to import a function from a DLL that accepts matrices and vectors. Matrices and vectors are passed as pointers to their underlying data buffers, along with size information for correct processing.

```MQL5
#import "mmlib.dll"
bool sgemm(uint flags, matrix<float> &C, const matrix<float> &A, const matrix<float> &B, ulong M, ulong N, ulong K, float alpha, float beta);
#import
```

```C++
extern "C" __declspec(dllexport) bool sgemm(UINT flags, float *C, const float *A, const float *B, UINT64 M, UINT64 N, UINT64 K, float alpha, float beta)
```

--------------------------------

### Install MetaTrader5 Python Module

Source: https://www.mql5.com/en/docs/python_metatrader5

Installs the MetaTrader5 Python package using pip. This is a prerequisite for connecting Python to MetaTrader 5.

```bash
pip install MetaTrader5
```

--------------------------------

### MQL5 Indicator Example: Using iBands

Source: https://www.mql5.com/en/docs/indicators/ibands

This MQL5 code demonstrates how to initialize and use the iBands function to create a Bollinger Bands indicator. It sets up indicator buffers, plots, and defines input parameters for customization. The example shows how to handle indicator creation based on user selection (iBands or IndicatorCreate).

```mql5
//+------------------------------------------------------------------+
//| Demo_iBands.mq5 |
//| Copyright 2011, MetaQuotes Software Corp. |
//| https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2000-2024, MetaQuotes Ltd."
#property link "https://www.mql5.com"
#property version "1.00"
#property description "The indicator demonstrates how to obtain data"
#property description "of indicator buffers for the iBands technical indicator."
#property description "A symbol and timeframe used for calculation of the indicator,"
#property description "are set by the symbol and period parameters."
#property description "The method of creation of the handle is set through the 'type' parameter (function type)."

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 3
//--- the Upper plot
#property indicator_label1 "Upper"
#property indicator_type1 DRAW_LINE
#property indicator_color1 clrMediumSeaGreen
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
//--- the Lower plot
#property indicator_label2 "Lower"
#property indicator_type2 DRAW_LINE
#property indicator_color2 clrMediumSeaGreen
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
//--- the Middle plot
#property indicator_label3 "Middle"
#property indicator_type3 DRAW_LINE
#property indicator_color3 clrMediumSeaGreen
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
//+------------------------------------------------------------------+
//| Enumeration of the methods of handle creation |
//+------------------------------------------------------------------+
enum Creation
{
Call_iBands, // use iBands
Call_IndicatorCreate // use IndicatorCreate
};
//--- input parameters
input Creation type=Call_iBands; // type of the function 
input int bands_period=20; // period of moving average
input int bands_shift=0; // shift
input double deviation=2.0; // number of standard deviations 
input ENUM_APPLIED_PRICE applied_price=PRICE_CLOSE; // type of price
input string symbol=" "; // symbol 
input ENUM_TIMEFRAMES period=PERIOD_CURRENT; // timeframe
//--- indicator buffers
double UpperBuffer[];
double LowerBuffer[];
double MiddleBuffer[];
//--- variable for storing the handle of the iBands indicator
int handle;
//--- variable for storing
string name=symbol;
//--- name of the indicator on a chart
string short_name;
//--- we will keep the number of values in the Bollinger Bands indicator
int bars_calculated=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
int OnInit()
{
//--- assignment of arrays to indicator buffers
SetIndexBuffer(0,UpperBuffer,INDICATOR_DATA);
SetIndexBuffer(1,LowerBuffer,INDICATOR_DATA);
SetIndexBuffer(2,MiddleBuffer,INDICATOR_DATA);
//--- set shift of each line
PlotIndexSetInteger(0,PLOT_SHIFT,bands_shift);
PlotIndexSetInteger(1,PLOT_SHIFT,bands_shift); 
PlotIndexSetInteger(2,PLOT_SHIFT,bands_shift); 
//--- determine the symbol the indicator is drawn for
name=symbol;
//--- delete spaces to the right and to the left
StringTrimRight(name);
StringTrimLeft(name);
//--- if it results in zero length of the 'name' string
if(StringLen(name)==0)
{

```

--------------------------------

### Install Plotting and Data Handling Libraries

Source: https://www.mql5.com/en/docs/python_metatrader5

Installs the matplotlib and pandas Python libraries, which are commonly used for data visualization and manipulation in conjunction with financial data.

```bash
pip install matplotlib
pip install pandas
```

--------------------------------

### MQL5 OpenCL Matrix Multiplication Setup and Execution

Source: https://www.mql5.com/en/docs/opencl/clbufferwrite

Initializes OpenCL, creates program and kernel for matrix multiplication, allocates device buffers for input and output matrices, sets kernel arguments, and executes the OpenCL kernel. It also includes reading results from the device and timing the execution.

```MQL5
//--- create the program and the kernel   
cl_prg = CLProgramCreate(cl_ctx, clSrc);
cl_krn = CLKernelCreate(cl_prg, "matricesMul");
//--- create all three buffers for three matrices   
cl_mem_in1=CLBufferCreate(cl_ctx, M*K*sizeof(float), CL_MEM_READ_WRITE);
cl_mem_in2=CLBufferCreate(cl_ctx, K*N*sizeof(float), CL_MEM_READ_WRITE);
//--- third matrix - output   
cl_mem_out=CLBufferCreate(cl_ctx, M*N*sizeof(float), CL_MEM_READ_WRITE);
//--- set the kernel arguments   
CLSetKernelArgMem(cl_krn, 0, cl_mem_in1);
CLSetKernelArgMem(cl_krn, 1, cl_mem_in2);
CLSetKernelArgMem(cl_krn, 2, cl_mem_out);
//--- write matrices to the device buffers   
CLBufferWrite(cl_mem_in1, 0, mat1);
CLBufferWrite(cl_mem_in2, 0, mat2);
CLBufferWrite(cl_mem_out, 0, matrix_opencl);
//--- OpenCL code execution time start   
start=GetTickCount();   
//--- set the parameters of the task working area and execute the OpenCL program   
uint offs[2] = {0, 0};
uint works[2] = {M, N};
start=GetTickCount();    
bool ex=CLExecute(cl_krn, 2, offs, works);
//--- calculate the result to the matrix   
if(CLBufferRead(cl_mem_out, 0, matrix_opencl))   
PrintFormat("[%d x %d] matrix read: ", matrix_opencl.Rows(), matrix_opencl.Cols());   
else   
Print("CLBufferRead(cl_mem_out, 0, matrix_opencl failed. Error ",GetLastError());    
uint time_opencl=GetTickCount()-start;    
Print("Compare calculation time using each method");   
PrintFormat("Naive product time = %d ms",time_naive);   
PrintFormat("MatMul product time = %d ms",time_matmul);   
PrintFormat("OpenCl product time = %d ms",time_opencl);    
//--- release all OpenCL contexts   
CLFreeAll(cl_ctx, cl_prg, cl_krn, cl_mem_in1, cl_mem_in2, cl_mem_out);
```

--------------------------------

### MQL5 Special Functions: OnInit, OnStart, OnDeinit

Source: https://www.mql5.com/en/docs/migration

This snippet demonstrates the MQL5 equivalents for MQL4's special functions. OnInit and OnDeinit handle initialization and deinitialization, analogous to MQL4's init and deinit. The start function's role is replaced by OnStart for scripts, OnCalculate for indicators, and OnTick for Expert Advisors.

```MQL5
void OnInit()
{
//--- Call function upon initialization
init();
}
void OnDeinit(const int reason)
{
//--- Call function upon deinitialization
deinit();
//---
}
```

--------------------------------

### MQL5 Normal Distribution Calculations Example

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat

Demonstrates how to use the MQL5 Statistical Library to perform calculations related to the Normal distribution. It covers calculating the probability of a random variable within a range, finding confidence intervals, and comparing calculated moments with theoretical values. This example requires the 'Normal.mqh' include file.

```MQL5
//+------------------------------------------------------------------+
//| NormalDistributionExample.mq5 |
//| Copyright 2016, MetaQuotes Software Corp. |
//| https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2000-2024, MetaQuotes Ltd."
#property link "https://www.mql5.com"
#property version "1.00"
//--- include the functions for calculating the normal distribution
#include <Math\Stat\Normal.mqh>
//+------------------------------------------------------------------+
//| Script program start function |
//+------------------------------------------------------------------+
void OnStart()
{
//--- set the parameters of the normal distribution
double mu=5.0;
double sigma=1.0;
PrintFormat("Normal distribution with parameters mu=%G and sigma=%G, calculation examples:",mu,sigma);
//--- set the interval
double x1=mu-sigma;
double x2=mu+sigma;
//--- variables for probability calculation
double cdf1,cdf2,probability;
//--- variables for error codes
int error_code1,error_code2;
//--- calculate the values of distribution functions
cdf1=MathCumulativeDistributionNormal(x1,mu,sigma,error_code1);
cdf2=MathCumulativeDistributionNormal(x2,mu,sigma,error_code2);
//--- check the error codes
if(error_code1==ERR_OK && error_code2==ERR_OK)
{
//--- calculate probability of a random variable in the range
probability=cdf2-cdf1;
//--- output the result
PrintFormat("1. Calculate probability of a random variable within the range of %.5f<x<%.5f",x1,x2);
PrintFormat(" Answer: Probability = %5.8f",probability);
}

//--- Find the value range of random variable x, corresponding to the 95% confidence level
probability=0.95; // set the confidence probability
//--- set the probabilities at the interval bounds
double p1=(1.0-probability)*0.5;
double p2=probability+(1.0-probability)*0.5;
//--- calculate the interval bounds
x1=MathQuantileNormal(p1,mu,sigma,error_code1);
x2=MathQuantileNormal(p2,mu,sigma,error_code2);
//--- check the error codes
if(error_code1==ERR_OK && error_code2==ERR_OK)
{
//--- output the result
PrintFormat("2. For confidence interval = %.2f, find the range of random variable",probability);
PrintFormat(" Answer: range is %5.8f <= x <=%5.8f",x1,x2);
}

PrintFormat("3. Compute the first 4 calculated and theoretical moments of the distribution");
//--- Generate an array of random numbers, calculate the first 4 moments and compare with the theoretical values
int data_count=1000000; // set the number of values and prepare an array
double data[];
ArrayResize(data,data_count);
//--- generate random values and store them into the array
for(int i=0; i<data_count; i++)
{
data[i]=MathRandomNormal(mu,sigma,error_code1);
}
//--- set the index of the initial value and the amount of data for calculation
int start=0;
int count=data_count;
//--- calculate the first 4 moments of the generated values
double mean=MathMean(data,start,count);
double variance=MathVariance(data,start,count);
double skewness=MathSkewness(data,start,count);
double kurtosis=MathKurtosis(data,start,count);
//--- variables for the theoretical moments
double normal_mean=0;
double normal_variance=0;
double normal_skewness=0;
double normal_kurtosis=0;
//--- display the values of the calculated moments
PrintFormat(" Mean Variance Skewness Kurtosis");

```

--------------------------------

### Get Symbol Information in Python using MetaTrader5

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5symbolinfo_py

This Python snippet demonstrates how to connect to MetaTrader5, select a symbol, and retrieve its properties using the symbol_info function. It shows how to access individual properties like spread and digits, and also how to convert the symbol info object to a dictionary for easier iteration. Ensure MetaTrader5 is installed and initialized before running.

```python
import MetaTrader5 as mt5

# display data on the MetaTrader 5 package
print("MetaTrader5 package author: ",mt5.__author__)
print("MetaTrader5 package version: ",mt5.__version__)

# establish connection to the MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed, error code =",mt5.last_error())
    quit()

# attempt to enable the display of the EURJPY symbol in MarketWatch
selected=mt5.symbol_select("EURJPY",True)
if not selected:
    print("Failed to select EURJPY")
    mt5.shutdown()
    quit()

# display EURJPY symbol properties
print("EURJPY: spread =",symbol_info.spread," digits =",symbol_info.digits)

# display symbol properties as a list
print("Show symbol_info(\"EURJPY\")._asdict():")
symbol_info_dict = mt5.symbol_info("EURJPY")._asdict()
for prop in symbol_info_dict:
    print(" {}={}".format(prop, symbol_info_dict[prop]))

# shut down connection to the MetaTrader 5 terminal
mt5.shutdown()
```

--------------------------------

### MQL5 Example: Fetching and Printing Recent Bars using CopyRates

Source: https://www.mql5.com/en/docs/series/copyrates

This MQL5 example demonstrates how to use the CopyRates function to fetch the latest 100 bars for the current symbol and timeframe. It then iterates through the first 10 copied bars, printing their time and price data (Open, High, Low, Close, Volume). Error handling is included for cases where data cannot be retrieved.

```mql5
void OnStart() 
{
//---
MqlRates rates[];
ArraySetAsSeries(rates,true);
int copied=CopyRates(Symbol(),0,0,100,rates);
if(copied>0)
{
Print("Bars copied: "+copied);
string format="open = %G, high = %G, low = %G, close = %G, volume = %d";
string out;
int size=fmin(copied,10);
for(int i=0;i<size;i++)
{
out=i+":"+TimeToString(rates[i].time);
out=out+" "+StringFormat(format,
rates[i].open,
rates[i].high,
rates[i].low,
rates[i].close,
rates[i].tick_volume);
Print(out);
}
}
else Print("Failed to get history data for the symbol ",Symbol());
}
```

--------------------------------

### Get Account Information as String (MQL5)

Source: https://www.mql5.com/en/docs/account/accountinfostring

Retrieves various string-based account properties using the AccountInfoString function. This example demonstrates how to fetch and print the broker's company name, deposit currency, client name, and trade server name.

```MQL5
void OnStart()
{
//--- Show all the information available from the function AccountInfoString()
Print("The name of the broker = ",AccountInfoString(ACCOUNT_COMPANY));
Print("Deposit currency = ",AccountInfoString(ACCOUNT_CURRENCY));
Print("Client name = ",AccountInfoString(ACCOUNT_NAME));
Print("The name of the trade server = ",AccountInfoString(ACCOUNT_SERVER));
}
```

--------------------------------

### Python Example: Initializing MetaTrader5 and Preparing a Buy Request

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5ordersend_py

This Python code snippet demonstrates how to initialize the MetaTrader5 terminal connection, retrieve symbol information, and prepare a buy request structure using the MetaTrader5 library. It includes error handling for initialization and symbol lookup.

```python
import time
import MetaTrader5 as mt5

# display data on the MetaTrader 5 package
print("MetaTrader5 package author: ", mt5.__author__)
print("MetaTrader5 package version: ", mt5.__version__)

# establish connection to the MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed, error code =", mt5.last_error())
    quit()

# prepare the buy request structure
symbol = "USDJPY"
symbol_info = mt5.symbol_info(symbol)
if symbol_info is None:
    print(symbol, "not found, can not call order_check()")
    mt5.shutdown()
    quit()

```

--------------------------------

### Get Relative Program Path for Indicator Resource in MQL5

Source: https://www.mql5.com/en/docs/runtime/resources

This MQL5 code demonstrates the correct way to reference a custom indicator that is included as a resource within another MQL5 program. It uses the GetRelativeProgramPath() function to dynamically retrieve the path, ensuring the indicator can correctly locate itself. The example shows its usage within an indicator's OnInit() function.

```MQL5
#property indicator_separate_window
#property indicator_plots 0
int handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
int OnInit()
{
//--- the wrong way to provide a link to itself
//--- string path="\\Experts\\SampleEA.ex5::Indicators\\SampleIndicator.ex5";
//--- the right way to receive a link to itself
string path=GetRelativeProgramPath();
//--- indicator buffers mapping
handle=iCustom(_Symbol,_Period,path,0,0);
if(handle==INVALID_HANDLE)
{
Print("Indicator: iCustom call: Error code=",GetLastError());
return(INIT_FAILED);
}
else Print("Indicator handle=",handle);
//--- 
return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
const int prev_calculated,
const int begin,
const double& price[])
{
//--- return value of prev_calculated for next call
return(rates_total);
}
```

--------------------------------

### Matrix Multiplication using OpenCL - MQL5

Source: https://www.mql5.com/en/docs/opencl/clbufferwrite

Example demonstrating parallel matrix multiplication using OpenCL in MQL5. It defines the OpenCL kernel for matrix multiplication and then uses MQL5 functions to initialize matrices, perform naive multiplication, and execute the OpenCL kernel for comparison.

```mql5
#define M 3000 // the number of rows in the first matrix
#define K 2000 // the number of columns in the first matrix is equal to the number of rows in the second one
#define N 3000 // the number of columns in the second matrix

//+------------------------------------------------------------------+
const string clSrc=
"#define N "+IntegerToString(N)+" \r\n"
+"#define K "+IntegerToString(K)+" \r\n"
+" \r\n"
+"__kernel void matricesMul( __global float *in1,\r\n"
+" __global float *in2,\r\n"
+" __global float *out ) \r\n"
+"{ \r\n"
+" int m = get_global_id( 0 ); \r\n"
+" int n = get_global_id( 1 ); \r\n"
+" float sum = 0.0; \r\n"
+" for( int k = 0; k < K; k ++ ) \r\n"
+" sum += in1[ m * K + k ] * in2[ k * N + n ]; \r\n"
+" out[ m * N + n ] = sum; \r\n"
+"} \r\n";
//+------------------------------------------------------------------+
//| Script program start function |
//+------------------------------------------------------------------+
void OnStart()
{
//--- initialize the random number generator
MathSrand((int)TimeCurrent());
//--- fill in the matrices of a given size with random values
matrixf mat1(M, K, MatrixRandom) ; // first matrix
matrixf mat2(K, N, MatrixRandom); // second matrix

//--- calculate the product of matrices using naive method
uint start=GetTickCount();
matrixf matrix_naive=matrixf::Zeros(M, N);// the result of multiplying two matrices is set here
for(int m=0; m<M; m++)
for(int k=0; k<K; k++)
for(int n=0; n<N; n++)
matrix_naive[m][n]+=mat1[m][k]*mat2[k][n];
uint time_naive=GetTickCount()-start;

//--- calculate the product of matrices via MatMull
start=GetTickCount();
matrixf matrix_matmul=mat1.MatMul(mat2);
uint time_matmul=GetTickCount()-start;

//--- calculate the product of matrices in OpenCL
matrixf matrix_opencl=matrixf::Zeros(M, N);
int cl_ctx; // context handle
if((cl_ctx=CLContextCreate(CL_USE_GPU_ONLY))==INVALID_HANDLE)
{
Print("OpenCL not found, leaving");
return;
}
int cl_prg; // program handle
int cl_krn; // kernel handle
int cl_mem_in1; // first (input) buffer handle
int cl_mem_in2; // second (input) buffer handle
int cl_mem_out; // third (output) buffer handle

```

--------------------------------

### Use Resource from Another EX5 File in MQL5

Source: https://www.mql5.com/en/docs/runtime/resources

This code example shows how to access a resource embedded in a different MQL5 executable file (e.g., a script). It requires specifying the path to the EX5 file and the resource name using the '::' separator.

```MQL5
//--- using a resource from a script in an EA   
ObjectSetString(0,my_bitmap_name,OBJPROP_BMPFILE,0,"\\Scripts\\Draw_Triangles_Script.ex5::Files\\triangle.bmp");
```

--------------------------------

### MQL5 Custom Event Handling with EventChartCustom Example

Source: https://www.mql5.com/en/docs/eventfunctions/eventchartcustom

An example demonstrating how to create a button on an MQL5 chart and use the EventChartCustom function to send custom events when the button is clicked. It also shows how to create and display a label on the chart.

```mql5
//+------------------------------------------------------------------+
//| ButtonClickExpert.mq5 |
//| Copyright 2009, MetaQuotes Software Corp. |
//| https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2009, MetaQuotes Software Corp."
#property link "https://www.mql5.com"
#property version "1.00"

string buttonID="Button";
string labelID="Info";
int broadcastEventID=5000;
//+------------------------------------------------------------------+
//| Expert initialization function |
//+------------------------------------------------------------------+
int OnInit()
{
//--- Create a button to send custom events
ObjectCreate(0,buttonID,OBJ_BUTTON,0,100,100);
ObjectSetInteger(0,buttonID,OBJPROP_COLOR,clrWhite);
ObjectSetInteger(0,buttonID,OBJPROP_BGCOLOR,clrGray);
ObjectSetInteger(0,buttonID,OBJPROP_XDISTANCE,100);
ObjectSetInteger(0,buttonID,OBJPROP_YDISTANCE,100);
ObjectSetInteger(0,buttonID,OBJPROP_XSIZE,200);
ObjectSetInteger(0,buttonID,OBJPROP_YSIZE,50);
ObjectSetString(0,buttonID,OBJPROP_FONT,"Arial");
ObjectSetString(0,buttonID,OBJPROP_TEXT,"Button");
ObjectSetInteger(0,buttonID,OBJPROP_FONTSIZE,10);
ObjectSetInteger(0,buttonID,OBJPROP_SELECTABLE,0);

//--- Create a label for displaying information
ObjectCreate(0,labelID,OBJ_LABEL,0,100,100);
ObjectSetInteger(0,labelID,OBJPROP_COLOR,clrRed);

```

--------------------------------

### Symbol Information as Pandas DataFrame

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5symbolselect_py

This example shows how to retrieve symbol information and display it as a Pandas DataFrame. This is useful for analyzing symbol properties in a tabular format. The `symbol_info_dict()` method is used to get the information, which is then converted into a DataFrame.

```python
import MetaTrader5 as mt5
import pandas as pd

# Initialize connection to the MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed, error code {}".format(mt5.last_error()))
    mt5.shutdown()

# get symbol information
symbol_info = mt5.symbol_info("EURCAD")

# get symbol_info()._asdict() as dataframe
if symbol_info:
    symbol_info_dict = symbol_info._asdict()
    symbol_frame = pd.DataFrame(list(symbol_info_dict.items()), columns=['property', 'value'])
    print(symbol_frame)

# shutdown connection to the MetaTrader 5 terminal
mt5.shutdown()
```

--------------------------------

### MQL5 MarketBookRelease Example

Source: https://www.mql5.com/en/docs/marketinformation/marketbookrelease

This MQL5 script demonstrates how to add and release the market depth for a symbol. It first calls MarketBookAdd to subscribe to DOM changes and then calls MarketBookRelease to unsubscribe. Error handling is included for both operations.

```MQL5
#define SYMBOL_NAME "GBPUSD"

//+------------------------------------------------------------------+
//| Script program start function |
//+------------------------------------------------------------------+
void OnStart()
{
//--- open the market depth for SYMBOL_NAME symbol
if(!MarketBookAdd(SYMBOL_NAME))
{
PrintFormat("MarketBookAdd(%s) failed. Error ", SYMBOL_NAME, GetLastError());
return;
}

//--- send the message about successfully opening the market depth to the journal
PrintFormat("The MarketBook for the '%s' symbol was successfully opened and a subscription to change it was received", SYMBOL_NAME);

//--- wait 2 seconds
Sleep(2000);

//--- upon completion, unsubscribe from the open market depth
//--- send the message about successfully unsubscribing from the market depth or about the error to the journal
ResetLastError();
if(MarketBookRelease(SYMBOL_NAME))
PrintFormat("MarketBook for the '%s' symbol was successfully closed", SYMBOL_NAME);
else
PrintFormat("Error %d occurred when closing MarketBook using the '%s' symbol", GetLastError(), SYMBOL_NAME);

/*
result:
The MarketBook for the 'GBPUSD' symbol was successfully opened and a subscription to change it was received
MarketBook for the 'GBPUSD' symbol was successfully closed
*/
}
```

--------------------------------

### PlaySound() Example: Sending Orders and Playing Sounds in MQL5

Source: https://www.mql5.com/en/docs/runtime/resources

Demonstrates how to send a trade request using OrderSend() and then play a sound file based on the result. It shows playing 'Ok.wav' on success and 'timeout.wav' on failure. The function relies on standard MQL5 trade request structures and sound files included in the terminal package.

```MQL5
//+------------------------------------------------------------------+
//| Calls standard OrderSend() and plays a sound |
//+------------------------------------------------------------------+
void OrderSendWithAudio(MqlTradeRequest &request, MqlTradeResult &result)
{
//--- send a request to a server
OrderSend(request,result);
//--- if a request is accepted, play sound Ok.wav 
if(result.retcode==TRADE_RETCODE_PLACED) PlaySound("Ok.wav");
//--- if fails, play alarm from file timeout.wav
else PlaySound("timeout.wav");
}
```

--------------------------------

### MQL5 iCustom Function Example

Source: https://www.mql5.com/en/docs/basis/function/events

This MQL5 code demonstrates how to use the iCustom() function to get a handle for a custom indicator named 'Custom Moving Average'. It shows how to specify parameters like period, shift, calculation mode, and the price type to apply.

```MQL5
void OnStart() 
{
//---
string terminal_path=TerminalInfoString(STATUS_TERMINAL_PATH);
int handle_customMA=iCustom(Symbol(),PERIOD_CURRENT, "Custom Moving Average",13,0, MODE_EMA,PRICE_TYPICAL);
if(handle_customMA>0)
Print("handle_customMA = ",handle_customMA);
else
Print("Cannot open or not EX5 file '"+terminal_path+"\\MQL5\\Indicators\\"+"Custom Moving Average.ex5'");
}
```

--------------------------------

### Example: Calculate Spread in MQL5

Source: https://www.mql5.com/en/docs/marketinformation/symbolinfodouble

Demonstrates how to calculate the spread between Ask and Bid prices for the current symbol using SymbolInfoDouble. It also shows how to retrieve fixed/floating spread information using SymbolInfoInteger and display the results using Comment().

```MQL5
void OnTick()
{
//--- obtain spread from the symbol properties
bool spreadfloat=SymbolInfoInteger(Symbol(),SYMBOL_SPREAD_FLOAT);
string comm=StringFormat("Spread %s = %I64d points\r\n",
spreadfloat?"floating":"fixed",
SymbolInfoInteger(Symbol(),SYMBOL_SPREAD));
//--- now let's calculate the spread by ourselves
double ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
double bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
double spread=ask-bid;
int spread_points=(int)MathRound(spread/SymbolInfoDouble(Symbol(),SYMBOL_POINT));
comm=comm+"Calculated spread = "+(string)spread_points+" points";
Comment(comm);
}
```

--------------------------------

### MQL5 Structure with Constructor and Destructor

Source: https://www.mql5.com/en/docs/basis/types/classes

This MQL5 code defines a structure named 'trade_settings' with member variables for take profit, stop loss, and slippage. It includes an explicit constructor to initialize these members and a destructor that prints a message upon destruction. The example also shows a compiler error that occurs when attempting to initialize such a structure using an initializing sequence.

```MQL5
struct trade_settings {
  double take; // values of the profit fixing price
  double stop; // value of the protective stop price
  uchar slippage; // value of the acceptable slippage
  //--- Constructor
  trade_settings() { take=0.0; stop=0.0; slippage=5; }
  //--- Destructor
  ~trade_settings() { Print("This is the end"); }
};
//--- Compiler will generate an error message that initialization is impossible
trade_settings my_set={0.0,0.0,5};
```

--------------------------------

### MQL5 MqlBookInfo Structure Definition and Usage

Source: https://www.mql5.com/en/docs/constants/structures/mqlbookinfo

Defines the MqlBookInfo structure which holds market depth data, including order type, price, and volume. An example demonstrates how to retrieve and use this information.

```MQL5
struct MqlBookInfo
{
ENUM_BOOK_TYPE type; // Order type from ENUM_BOOK_TYPE enumeration
double price; // Price
long volume; // Volume
double volume_real; // Volume with greater accuracy
};

// Example Usage:
MqlBookInfo priceArray[];
bool getBook = MarketBookGet(NULL, priceArray);
if (getBook)
{
  int size = ArraySize(priceArray);
  Print("MarketBookInfo about ", Symbol());
}
else
{
  Print("Failed to receive DOM for the symbol ", Symbol());
}
```

--------------------------------

### Python: Initialize MetaTrader 5 and Get Symbols

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5symbolsget_py

Initializes the MetaTrader 5 terminal connection and retrieves all available financial symbols. It then prints the total count and details of the first five symbols. This function requires the MetaTrader5 package.

```python
import MetaTrader5 as mt5

# display data on the MetaTrader 5 package
print("MetaTrader5 package author: ", mt5.__author__)
print("MetaTrader5 package version: ", mt5.__version__)

# establish connection to the MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed, error code =", mt5.last_error())
    quit()

# get all symbols
symbols = mt5.symbols_get()
print('Symbols: ', len(symbols))
count = 0
# display the first five ones
for s in symbols:
    count += 1
    print("{}. {}".format(count, s.name))
    if count == 5:
        break
print()
```

--------------------------------

### MQL5 Structure Member Access Example

Source: https://www.mql5.com/en/docs/basis/types/classes

Illustrates how to define a structure ('trade_settings') in MQL5 and access its members using the dot (.) operator. It shows the creation and initialization of a structure variable and conditional assignment to its members.

```MQL5
struct trade_settings
{
double take; // values of the profit fixing price
double stop; // value of the protective stop price
uchar slippage; // value of the acceptable slippage
};

//--- create up and initialize a variable of the trade_settings type
trade_settings my_set={0.0,0.0,5};

if (input_TP>0) my_set.take=input_TP;
```

--------------------------------

### Get Open Positions Count (Python)

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5positionstotal_py

This function retrieves the total number of open positions in the MetaTrader 5 terminal. It requires the MetaTrader5 package to be installed and initialized. The function returns an integer representing the count of positions.

```python
import MetaTrader5 as mt5

# display data on the MetaTrader 5 package
print("MetaTrader5 package author: ", mt5.__author__)
print("MetaTrader5 package version: ", mt5.__version__)

# establish connection to MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed, error code =", mt5.last_error())
    quit()

# check the presence of open positions
positions_total = mt5.positions_total()
if positions_total > 0:
    print("Total positions=", positions_total)
else:
    print("Positions not found")

# shut down connection to the MetaTrader 5 terminal
mt5.shutdown()
```

--------------------------------

### Get Last Tick Data using Python (MQL5)

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5symbolinfotick_py

This Python code snippet demonstrates how to retrieve the last tick information for a financial instrument like 'GBPUSD' using the MQL5 library. It initializes the MetaTrader5 connection, selects the symbol, fetches the tick data, and displays it in a readable format. It also shows how to access tick data fields as a dictionary. Ensure the MetaTrader5 library is installed and a terminal is running.

```python
import MetaTrader5 as mt5

# display data on the MetaTrader 5 package
print("MetaTrader5 package author: ", mt5.__author__)
print("MetaTrader5 package version: ", mt5.__version__)

# establish connection to the MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed, error code =", mt5.last_error())
    quit()

# attempt to enable the display of the GBPUSD in MarketWatch
selected = mt5.symbol_select("GBPUSD", True)
if not selected:
    print("Failed to select GBPUSD")
    mt5.shutdown()
    quit()

# display the last GBPUSD tick
lasttick = mt5.symbol_info_tick("GBPUSD")
print(lasttick)

# display tick field values in the form of a list
print("Show symbol_info_tick(\"GBPUSD\")._asdict():")
symbol_info_tick_dict = mt5.symbol_info_tick("GBPUSD")._asdict()
for prop in symbol_info_tick_dict:
    print(" {}"".format(prop, symbol_info_tick_dict[prop]))

# shut down connection to the MetaTrader 5 terminal
mt5.shutdown()
```

--------------------------------

### MQL5 Structure Alignment and Size Variation

Source: https://www.mql5.com/en/docs/basis/types/classes

Illustrates how the order of members in an MQL5 structure can affect its total size due to alignment. This example defines a structure with 'char', 'int', and 'short' members and prints their individual sizes and the total structure size, highlighting potential padding.

```MQL5
struct CharIntShort pack(4)
{
char c; // sizeof(char)=1
int i; // sizeof(double)=4
short s; // sizeof(short)=2
};

//--- declare a simple structure instance 
CharIntShort ch_in_sh;

//--- display the size of each structure member  
Print("sizeof(ch_in_sh.c)=",sizeof(ch_in_sh.c));
Print("sizeof(ch_in_sh.i)=",sizeof(ch_in_sh.i));
Print("sizeof(ch_in_sh.s)=",sizeof(ch_in_sh.s));

//--- make sure the size of POD structure is equal to the sum of its members' size
Print("sizeof(CharIntShort)=",sizeof(CharIntShort));
```

--------------------------------

### MQL5: Get OpenCL Platform and Device String Information using CLGetInfoString

Source: https://www.mql5.com/en/docs/opencl/clgetinfostring

This MQL5 code snippet demonstrates how to initialize an OpenCL context and retrieve various string properties for the OpenCL platform and devices using the CLGetInfoString function. It covers properties like platform name, vendor, version, profile, extensions, device name, and more. Error handling is included for context creation.

```MQL5
void OnStart()
{
int cl_ctx;
string str;
//--- initialize OpenCL context
if((cl_ctx=CLContextCreate(CL_USE_GPU_ONLY))==INVALID_HANDLE)
{
Print("OpenCL not found");
return;
}

//--- Display information about the platform
if(CLGetInfoString(cl_ctx,CL_PLATFORM_NAME,str))
Print("OpenCL platform name: ",str);
if(CLGetInfoString(cl_ctx,CL_PLATFORM_VENDOR,str))
Print("OpenCL platform vendor: ",str);
if(CLGetInfoString(cl_ctx,CL_PLATFORM_VERSION,str))
Print("OpenCL platform ver: ",str);
if(CLGetInfoString(cl_ctx,CL_PLATFORM_PROFILE,str))
Print("OpenCL platform profile: ",str);
if(CLGetInfoString(cl_ctx,CL_PLATFORM_EXTENSIONS,str))
Print("OpenCL platform ext: ",str);

//--- Display information about the device
if(CLGetInfoString(cl_ctx,CL_DEVICE_NAME,str))
Print("OpenCL device name: ",str);
if(CLGetInfoString(cl_ctx,CL_DEVICE_PROFILE,str))
Print("OpenCL device profile: ",str);
if(CLGetInfoString(cl_ctx,CL_DEVICE_BUILT_IN_KERNELS,str))
Print("OpenCL device kernels: ",str);
if(CLGetInfoString(cl_ctx,CL_DEVICE_EXTENSIONS,str))
Print("OpenCL device ext: ",str);
if(CLGetInfoString(cl_ctx,CL_DEVICE_VENDOR,str))
Print("OpenCL device vendor: ",str);
if(CLGetInfoString(cl_ctx,CL_DEVICE_VERSION,str))
Print("OpenCL device ver: ",str);
if(CLGetInfoString(cl_ctx,CL_DEVICE_OPENCL_C_VERSION,str))
Print("OpenCL open c ver: ",str);

//--- free OpenCL context
CLContextFree(cl_ctx);
}
```

--------------------------------

### MQL5 Example: Retrieving and Printing Tick Data

Source: https://www.mql5.com/en/docs/constants/structures/mqltick

Demonstrates how to use the SymbolInfoTick() function to retrieve the latest tick data for the current symbol into an MqlTick structure and print its details. Includes error handling for the function call.

```MQL5
void OnTick() {
    MqlTick last_tick;
    //---
    if(SymbolInfoTick(Symbol(),last_tick)) {
        Print(last_tick.time,": Bid = ",last_tick.bid,
              " Ask = ",last_tick.ask," Volume = ",last_tick.volume);
    }
    else Print("SymbolInfoTick() failed, error = ",GetLastError());
    //---
}
```

--------------------------------

### Get Historical Bar Data using copy_rates_range in Python

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5copyratesrange_py

This snippet demonstrates how to retrieve historical bar data from the MetaTrader 5 terminal using the `copy_rates_range` function. It requires the `MetaTrader5`, `pandas`, and `pytz` libraries. The function takes the symbol, timeframe, start date, and end date as input and returns a NumPy array containing the bar data.

```Python
from datetime import datetime
import MetaTrader5 as mt5
import pandas as pd
import pytz

# display data on the MetaTrader 5 package
print("MetaTrader5 package author: ",mt5.__author__)
print("MetaTrader5 package version: ",mt5.__version__)

pd.set_option('display.max_columns', 500)
pd.set_option('display.width', 1500)

# establish connection to MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed, error code =",mt5.last_error())
    quit()

# set time zone to UTC
timezone = pytz.timezone("Etc/UTC")
# create 'datetime' objects in UTC time zone to avoid the implementation of a local time zone offset
utc_from = datetime(2020, 1, 10, tzinfo=timezone)
utc_to = datetime(2020, 1, 11, hour = 13, tzinfo=timezone)
# get bars from USDJPY M5 within the interval of 2020.01.10 00:00 - 2020.01.11 13:00 in UTC time zone
rates = mt5.copy_rates_range("USDJPY", mt5.TIMEFRAME_M5, utc_from, utc_to)

# shut down connection to the MetaTrader 5 terminal
mt5.shutdown()

# display each element of obtained data in a new line
print("Display obtained data 'as is'")
counter=0
for rate in rates:
    counter+=1
    if counter<=10:
        print(rate)

# create DataFrame out of the obtained data
rates_frame = pd.DataFrame(rates)
# convert time in seconds into the 'datetime' format
rates_frame['time']=pd.to_datetime(rates_frame['time'], unit='s')
```

--------------------------------

### MQL5 Execution Status

Source: https://www.mql5.com/en/docs/database

Demonstrates how to access the execution status of a database operation in MQL5, represented by 'CLExecutionStatus' and 'DatabaseOpen'. This is crucial for confirming successful database connections or operation starts.

```MQL5
CLExecutionStatus
DatabaseOpen
```

--------------------------------

### MQL5 CopyRates Function Overloads for Retrieving Historical Data

Source: https://www.mql5.com/en/docs/series/copyrates

This snippet demonstrates the three overloads of the MQL5 CopyRates function used to retrieve historical price data. These overloads allow users to specify the data range by starting position and count, by start time and count, or by a start and end time. The function populates an MqlRates array with the requested data.

```mql5
int CopyRates(
string symbol_name, // symbol name 
ENUM_TIMEFRAMES timeframe, // period 
int start_pos, // start position 
int count, // data count to copy 
MqlRates rates_array[] // target array to copy 
);

int CopyRates(
string symbol_name, // symbol name 
ENUM_TIMEFRAMES timeframe, // period 
datetime start_time, // start date and time 
int count, // data count to copy 
MqlRates rates_array[] // target array to copy 
);

int CopyRates(
string symbol_name, // symbol name 
ENUM_TIMEFRAMES timeframe, // period 
datetime start_time, // start date and time 
datetime stop_time, // end date and time 
MqlRates rates_array[] // target array to copy 
);
```

--------------------------------

### Display Tick Data using Python and MetaTrader5

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5copyticksrange_py

This snippet shows how to display tick data obtained from MetaTrader 5. It uses the MetaTrader5 Python package to fetch ticks and then prints them both as raw tuples and as a pandas DataFrame. Ensure the MetaTrader5 package is installed (`pip install MetaTrader5`).

```python
# display data  
print("\nDisplay dataframe with ticks")  
print(ticks_frame.head(10))
```

--------------------------------

### Get MetaTrader 5 Terminal Build and Architecture (MQL5)

Source: https://www.mql5.com/en/docs/check/terminalinfointeger

This MQL5 script demonstrates how to use the TerminalInfoInteger function to retrieve the build number of the running MetaTrader 5 terminal and whether it is a 64-bit version. It then prints this information to the journal. No external libraries are required.

```MQL5
void OnStart()
{
//--- get the build number of the running terminal and its "64-bit terminal" property
int build = TerminalInfoInteger(TERMINAL_BUILD);
bool x64 = TerminalInfoInteger(TERMINAL_X64);

//--- print the obtained terminal data in the journal
PrintFormat("MetaTrader 5 %s build %d", (x64 ? "x64" : "x32"), build);
/*
result:
MetaTrader 5 x64 build 4330
*/
}
```

--------------------------------

### Get OpenCL Error Description (MQL5)

Source: https://www.mql5.com/en/docs/opencl

Retrieves the text description of an OpenCL error. It can be used with a specific error code or CL_LAST_ERROR to get the description of the most recent error. Error codes can be found at https://registry.khronos.org/OpenCL/specs/3.0-unified/html/OpenCL_API.html#CL_SUCCESS.

```MQL5
//--- get the code of the last OpenCL error
int code= (int)CLGetInfoInteger(0,CL_LAST_ERROR);
stringdesc; // to get an error text description

//--- use the error code to get an error text description
if(!CLGetInfoString(code,CL_ERROR_DESCRIPTION,desc))
  desc="cannot get OpenCL error description,"+ (string)GetLastError();
Print(desc);

//--- in order to get the description of the last OpenCL error without getting the code first, pass CL_LAST_ERROR
if(!CLGetInfoString(CL_LAST_ERROR,CL_ERROR_DESCRIPTION,desc))
  desc="cannot get OpenCL error description,"+ (string)GetLastError();
Print(desc);
```

--------------------------------

### MQL5 Inheritance and Alignment Padding

Source: https://www.mql5.com/en/docs/basis/types/classes

Demonstrates how alignment in inheritance can lead to increased structure size. This example shows a 'Parent' structure and a 'Children' structure inheriting from it, with explicit alignment settings, to explain how padding is added to ensure proper alignment of child members.

```MQL5
struct Parent
{
char c; // sizeof(char)=1
};

struct Children pack(2) : Parent
{
sT s; // sizeof(short)=2
};
```

--------------------------------

### Helper Function to Get Max, Min, and Step Values (MQL5)

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/beta

A utility function to determine maximum, minimum, and step values, likely used for generating sequences or plotting ranges. It takes references to max, min, and step variables and populates them.

```MQL5
void GetMaxMinStepValues(double &maxv,double &minv,double &stepv)
{
   // Implementation details for calculating step would be here.
   // This is a placeholder based on the provided text structure.
}
```

--------------------------------

### MQL5: Opening a Sell Position with OrderSend

Source: https://www.mql5.com/en/docs/constants/tradingconstants/enum_trade_request_actions

Illustrates how to open a Sell position using the OrderSend() function in MQL5. This example configures the trade action for immediate execution (TRADE_ACTION_DEAL) and specifies details like symbol, volume, order type, price, deviation, and magic number. Includes error handling and output of operation results.

```MQL5
#define EXPERT_MAGIC 123456 // MagicNumber of the expert
//+------------------------------------------------------------------+
//| Opening Sell position |
//+------------------------------------------------------------------+
void OnStart()
{
//--- declare and initialize the trade request and result of trade request
MqlTradeRequest request={};
MqlTradeResult result={};
//--- parameters of request
request.action =TRADE_ACTION_DEAL; // type of trade operation
request.symbol =Symbol(); // symbol
request.volume =0.2; // volume of 0.2 lot
request.type =ORDER_TYPE_SELL; // order type
request.price =SymbolInfoDouble(Symbol(),SYMBOL_BID); // price for opening
request.deviation=5; // allowed deviation from the price
request.magic =EXPERT_MAGIC; // MagicNumber of the order
//--- send the request
if(!OrderSend(request,result))
PrintFormat("OrderSend error %d",GetLastError()); // if unable to send the request, output the error code
//--- information about the operation
PrintFormat("retcode=%u deal=%I64u order=%I64u",result.retcode,result.deal,result.order);
}
//+------------------------------------------------------------------+
```

--------------------------------

### Initialize and Get Terminal Info in Python

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5terminalinfo_py

This Python snippet demonstrates how to initialize a connection to the MetaTrader 5 terminal, retrieve terminal information using mt5.terminal_info(), and display it in various formats including raw output, a dictionary, and a pandas DataFrame. It also includes error handling for initialization and ensures the connection is shut down.

```python
import MetaTrader5 as mt5
import pandas as pd

# display data on the MetaTrader 5 package
print("MetaTrader5 package author: ", mt5.__author__)
print("MetaTrader5 package version: ", mt5.__version__)

# establish connection to the MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed, error code =", mt5.last_error())
    quit()

# display data on MetaTrader 5 version
print(mt5.version())

# display info on the terminal settings and status
terminal_info = mt5.terminal_info()
if terminal_info != None:
    # display the terminal data 'as is'
    print(terminal_info)

    # display data in the form of a list
    print("Show terminal_info()._asdict():")
    terminal_info_dict = mt5.terminal_info()._asdict()
    for prop in terminal_info_dict:
        print(" {}={}".format(prop, terminal_info_dict[prop]))
    print()

    # convert the dictionary into DataFrame and print
    df = pd.DataFrame(list(terminal_info_dict.items()), columns=['property', 'value'])
    print("terminal_info() as dataframe:")
    print(df)

# shut down connection to the MetaTrader 5 terminal
mt5.shutdown()
```

--------------------------------

### MQL5: CPerson Class Constructors and Object Initialization

Source: https://www.mql5.com/en/docs/basis/types/classes

Demonstrates the definition and usage of multiple constructors for the `CPerson` class in MQL5. It includes a default constructor, a parametric constructor that parses a full name, and a constructor utilizing an initialization list. The `OnStart` function shows how to create `CPerson` objects using these constructors and dynamic allocation.

```MQL5
//+------------------------------------------------------------------+
//| A class for storing the name of a character |
//+------------------------------------------------------------------+
class CPerson
{
string m_first_name; // First name
string m_second_name; // Second name
public:
//--- An empty default constructor
CPerson() {Print(__FUNCTION__);};
//--- A parametric constructor
CPerson(string full_name);
//--- A constructor with an initialization list
CPerson(string surname,string name): m_second_name(surname), m_first_name(name) {};
void PrintName(){PrintFormat("Name=%s Surname=%s",m_first_name,m_second_name);};
};
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
CPerson::CPerson(string full_name)
{
int pos=StringFind(full_name," ");
if(pos>=0)
{
m_first_name=StringSubstr(full_name,0,pos);
m_second_name=StringSubstr(full_name,pos+1);
}
}
//+------------------------------------------------------------------+
//| Script program start function |
//+------------------------------------------------------------------+
void OnStart()
{
//--- Get an error "default constructor is not defined"
//CPerson people[5]; // This line would cause an error if uncommented, as default constructor is not explicitly defined for this usage.
CPerson Tom="Tom Sawyer"; // Tom Sawyer
CPerson Huck("Huckleberry","Finn"); // Huckleberry Finn
CPerson *Pooh = new CPerson("Winnie","Pooh"); // Winnie the Pooh
//--- Output values
Tom.PrintName();
Huck.PrintName();
Pooh.PrintName();

//--- Delete a dynamically created object
delete Pooh;
}
```

--------------------------------

### Get Symbol Information (Python)

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5symbolsget_py

Fetches detailed information for a specific trading symbol. This includes properties like whether it's a custom symbol, chart mode, selection status, and session-related deal and order counts.

```python
symbol_info = mt5.symbol_info('EURUSD')
```

--------------------------------

### Get Total Symbol Count (Python)

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5symbolsget_py

Retrieves the total number of symbols available in the connected MetaTrader 5 terminal. This can be useful for understanding the scope of available trading instruments.

```python
symbols_total = mt5.symbols_total()
```

--------------------------------

### MQL5 market_book_add Function Example

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5marketbookadd_py

This MQL5 code snippet demonstrates how to use the market_book_add function to subscribe to Market Depth change events for a given financial instrument. It requires the symbol name as input and returns a boolean indicating success or failure.

```MQL5
bool success = market_book_add("EURUSD"); // Subscribe to Market Depth for EURUSD
```

--------------------------------

### Retrieve GBPUSD Rate Data in MQL5

Source: https://www.mql5.com/en/docs/python_metatrader5

This example shows how to retrieve historical rate data for GBPUSD using the `eurgbp_rates` function in MQL5. It fetches a specified number of rate bars, returning time, open, high, low, close, volume, spread, and real volume.

```mql5
eurgbp_rates( 1000 )
(1582236360, 0.83767, 0.83767, 0.83764, 0.83765, 23, 9, 0)
(1582236420, 0.83765, 0.83765, 0.83764, 0.83765, 15, 8, 0)
(1582236480, 0.83765, 0.83766, 0.83762, 0.83765, 19, 7, 0)
(1582236540, 0.83765, 0.83768, 0.83758, 0.83763, 39, 6, 0)
(1582236600, 0.83763, 0.83768, 0.83763, 0.83767, 21, 6, 0)
(1582236660, 0.83767, 0.83775, 0.83765, 0.83769, 63, 5, 0)
(1582236720, 0.83769, 0.8377, 0.83758, 0.83764, 40, 7, 0)
(1582236780, 0.83766, 0.83769, 0.8376, 0.83766, 37, 6, 0)
(1582236840, 0.83766, 0.83772, 0.83763, 0.83772, 22, 6, 0)
(1582236900, 0.83772, 0.83773, 0.83768, 0.8377, 36, 5, 0)
```

--------------------------------

### Get OpenCL Device Information using CLGetInfoInteger

Source: https://www.mql5.com/en/docs/opencl/clgetinfointeger

This MQL5 code snippet demonstrates how to initialize an OpenCL context and retrieve various integer properties of the OpenCL device, such as its type, vendor ID, compute units, clock frequency, and memory sizes. It utilizes CLGetInfoInteger to fetch these details and prints them to the console. The snippet also shows how to properly free the OpenCL context.

```MQL5
void OnStart() 
{
   int cl_ctx;
   //--- initialize OpenCL context
   if((cl_ctx=CLContextCreate(CL_USE_GPU_ONLY))==INVALID_HANDLE)
   {
      Print("OpenCL not found");
      return;
   }
   //--- Display general information about OpenCL device
   Print("OpenCL type: ",EnumToString((ENUM_CL_DEVICE_TYPE)CLGetInfoInteger(cl_ctx,CL_DEVICE_TYPE)));
   Print("OpenCL vendor ID: ",CLGetInfoInteger(cl_ctx,CL_DEVICE_VENDOR_ID));
   Print("OpenCL units: ",CLGetInfoInteger(cl_ctx,CL_DEVICE_MAX_COMPUTE_UNITS));
   Print("OpenCL freq: ",CLGetInfoInteger(cl_ctx,CL_DEVICE_MAX_CLOCK_FREQUENCY)," MHz");
   Print("OpenCL global mem: ",CLGetInfoInteger(cl_ctx,CL_DEVICE_GLOBAL_MEM_SIZE)," bytes");
   Print("OpenCL local mem: ",CLGetInfoInteger(cl_ctx,CL_DEVICE_LOCAL_MEM_SIZE)," bytes");
   //--- free OpenCL context
   CLContextFree(cl_ctx);
}
```

--------------------------------

### Use Resource from Same Folder EX5 File in MQL5

Source: https://www.mql5.com/en/docs/runtime/resources

This snippet illustrates how to call a resource from another EX5 file when both files are in the same directory. The path to the calling EX5 file is omitted, and the system searches in the program's current folder.

```MQL5
//--- call script resource in an EA without specifying the path   
ObjectSetString(0,my_bitmap_name,OBJPROP_BMPFILE,0,"Draw_Triangles_Script.ex5::Files\\triangle.bmp");
```

--------------------------------

### MQL5 Example: Copying and Printing Rates Data

Source: https://www.mql5.com/en/docs/constants/structures/mqlrates

Demonstrates how to use the CopyRates function to retrieve historical price data into an MqlRates array. It includes error handling for the CopyRates function and prints the number of bars copied. This function is essential for accessing time-series data in MQL5.

```mql5
void OnStart() {
  MqlRates rates[];
  int copied=CopyRates(NULL,0,0,100,rates);
  if(copied<=0)
    Print("Error copying price data ",GetLastError());
  else Print("Copied ",ArraySize(rates)," bars");
}
```

--------------------------------

### Get DirectX Graphics Context Size

Source: https://www.mql5.com/en/docs/directx/dxcontextcreate

Retrieves the current dimensions (width and height) of a specified graphics context. Returns the width and height via reference parameters. Requires a valid context handle.

```MQL5
void DXContextGetSize(
  int context_handle, // handle of the graphic context
  uint &width,        // output parameter for width in pixels
  uint &height        // output parameter for height in pixels
);

```

--------------------------------

### Get Terminal Data Paths in MQL5

Source: https://www.mql5.com/en/docs/files

Retrieves the paths for the terminal data folder and the common data folder using the TerminalInfoString() function. These paths are crucial for file operations within the MQL5 sandbox.

```MQL5
//--- Folder that stores the terminal data
string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);
//--- Common folder for all client terminals
string common_data_path=TerminalInfoString(TERMINAL_COMMONDATA_PATH);
```

--------------------------------

### Get DirectX Graphics Context Colors

Source: https://www.mql5.com/en/docs/directx/dxcontextcreate

Retrieves the current color buffer content of a graphics context as a texture. Requires a valid context handle. The returned texture can be further processed or saved.

```MQL5
int DXContextGetColors(
  int context_handle // handle of the graphic context
);

```

--------------------------------

### MQL5: Include Resources with #resource Directive

Source: https://www.mql5.com/en/docs/runtime/resources

Demonstrates the use of the #resource preprocessor directive in MQL5 to embed external files, such as images (BMP) and sound (WAV), directly into the compiled EX5 executable. This eliminates the need to distribute these resource files separately, simplifying deployment.

```MQL5
#resource "path_to_resource_file"
```

--------------------------------

### MQL5: Generate and Visualize Logistic Distribution Sample

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/logistic

This MQL5 example generates a large sample of pseudorandom numbers from a logistic distribution using MathRandomLogistic. It then calculates histogram data and compares it with the theoretical distribution curve generated by MathProbabilityDensityLogistic. The output is visualized using the CGraphic class.

```MQL5
#include <Graphics\Graphic.mqh>
#include <Math\Stat\Logistic.mqh>
#include <Math\Stat\Math.mqh>

input double mu_par=6;
input double sigma_par=2;

void OnStart()
{
  ChartSetInteger(0,CHART_SHOW,false);
  MathSrand(GetTickCount());

  long chart=0;
  string name="GraphicNormal";
  int n=1000000;
  int ncells=51;
  double x[], y[], data[], max, min;

  MathRandomLogistic(mu_par,sigma_par,n,data);
  CalculateHistogramArray(data, x, y, max, min, ncells);

  double step;
  GetMaxMinStepValues(max, min, step);
  step=MathMin(step,(max-min)/ncells);

  double x2[], y2[];
  MathSequence(min,max,step,x2);
  MathProbabilityDensityLogistic(x2, mu_par, sigma_par, false, y2);

  double theor_max=y2[ArrayMaximum(y2)];
  double sample_max=y[ArrayMaximum(y)];
  double k=sample_max/theor_max;
  for(int i=0; i<ncells; i++)
    y[i]/=k;

  CGraphic graphic;
  if(ObjectFind(chart,name)<0)
    graphic.Create(chart,name,0,0,0,780,380);
  else
    graphic.Attach(chart,name);

  graphic.BackgroundMain(StringFormat("Logistic distribution mu=%G sigma=%G",mu_par,sigma_par));
  graphic.BackgroundMainSize(16);
  graphic.YAxis().AutoScale(false);
  graphic.YAxis().Max(theor_max);
  graphic.YAxis().Min(0);

  graphic.CurveAdd(x,y,CURVE_HISTOGRAM,"Sample").HistogramWidth(6);
  graphic.CurveAdd(x2,y2,CURVE_LINES,"Theory");
  graphic.CurvePlotAll();
  graphic.Update();
}

bool CalculateHistogramArray(const double &data[],double &intervals[],double &frequency[],
 double &maxv,double &minv,const int cells=10)
{
  if(cells<=1) return (false);
  int size=ArraySize(data);
  if(size<cells*10) return (false);
  minv=data[ArrayMinimum(data)];
  maxv=data[ArrayMaximum(data)];
  double range=maxv-minv;
  double width=range/cells;
  if(width==0) return false;
  ArrayResize(intervals,cells);
  ArrayResize(frequency,cells);

  for(int i=0; i<cells; i++)
  {
    intervals[i]=minv+(i+0.5)*width;
    frequency[i]=0;
  }

  for(int i=0; i<size; i++)
  {
    int ind=int((data[i]-minv)/width);
    if(ind>=cells) ind=cells-1;
    frequency[ind]++;
  }
  return (true);
}


```

--------------------------------

### Getting Plot Properties in MQL5

Source: https://www.mql5.com/en/docs/customind

Demonstrates how to retrieve the current value of an integer property for a specific plot using PlotIndexGetInteger. This can be useful for dynamic adjustments or checks within the indicator's logic.

```mql5
long PlotIndexGetInteger(int plot_index, int prop_id);
```

--------------------------------

### Include Local MQL5 Header File

Source: https://www.mql5.com/en/docs/basis/preprosessor/include

Shows how to include a header file from the current source file's directory using quotation marks. The preprocessor searches only in the current directory.

```MQL5
#include "mylib.mqh"
```

--------------------------------

### Get Trading Account Information with MQL5 (Python)

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5accountinfo_py

This Python snippet demonstrates how to retrieve and display information about the current trading account using the MetaTrader5 library. It covers initializing the connection, logging in, fetching account details, and displaying them in various formats (raw named tuple, dictionary, and DataFrame). It also includes error handling for connection issues.

```python
import MetaTrader5 as mt5
import pandas as pd

# display data on the MetaTrader 5 package
print("MetaTrader5 package author: ", mt5.__author__)
print("MetaTrader5 package version: ", mt5.__version__)

# establish connection to the MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed, error code =", mt5.last_error())
    quit()

# connect to the trade account specifying a password and a server
# Replace with your actual login and password
authorized = mt5.login(25115284, password="gqz0343lbdm")
if authorized:
    account_info = mt5.account_info()
    if account_info != None:
        # display trading account data 'as is'
        print(account_info)
        # display trading account data in the form of a dictionary
        print("Show account_info()._asdict():")
        account_info_dict = mt5.account_info()._asdict()
        for prop in account_info_dict:
            print(" {}={}".format(prop, account_info_dict[prop]))
        print()

        # convert the dictionary into DataFrame and print
        df = pd.DataFrame(list(account_info_dict.items()), columns=['property', 'value'])
        print("account_info() as dataframe:")
        print(df)
    else:
        print("Failed to get account info, error code =", mt5.last_error())
else:
    print("failed to connect to trade account with password, error code =", mt5.last_error())

# shut down connection to the MetaTrader 5 terminal
mt5.shutdown()
```

--------------------------------

### Python: Get Symbols Containing Specific String

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5symbolsget_py

Retrieves financial symbols from the MetaTrader 5 terminal whose names contain a specific string, using a wildcard pattern. This function relies on the MetaTrader5 package.

```python
import MetaTrader5 as mt5

# establish connection to the MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed, error code =", mt5.last_error())
    quit()

# get symbols containing RU in their names
ru_symbols = mt5.symbols_get("*RU*")
print('len(*RU*): ', len(ru_symbols))
for s in ru_symbols:
    print(s.name)
print()
```

--------------------------------

### DXTextureCreate Function Documentation

Source: https://www.mql5.com/en/docs/directx/dxtexturecreate

This section details the DXTextureCreate function, its parameters, return value, and usage notes.

```APIDOC
## DXTextureCreate

### Description
Creates a 2D texture out of a rectangle of a specified size cut from a passed image.

### Method
`int` (Return Type)

### Parameters
#### Path Parameters
None

#### Query Parameters
None

#### Request Body
None

#### Function Parameters
- **context** (int) - Required - Graphic context handle created in `DXContextCreate()`.
- **format** (ENUM_DX_FORMAT) - Required - Pixel color format.
- **width** (uint) - Required - Width of the source image.
- **height** (uint) - Required - Height of the source image.
- **data** (const void&[]) - Required - Array of source image pixels.
- **data_x** (uint) - Required - X coordinate of the rectangle used to create the texture.
- **data_y** (uint) - Required - Y coordinate of the rectangle used to create the texture.
- **data_width** (uint) - Required - Width of the rectangle used to create the texture.
- **data_height** (uint) - Required - Height of the rectangle used to create the texture.

### Request Example
```c
int textureHandle = DXTextureCreate(context, DX_FORMAT_R8G8B8A8_UNORM, imageWidth, imageHeight, imageData, dataX, dataY, dataWidth, dataHeight);
```

### Response
#### Success Response
- **Texture handle** (int) - A valid handle to the created texture.

#### Error Response
- **INVALID_HANDLE** (int) - Returned in case of an error. Call `GetLastError()` to get the error code.

### Notes
- A created handle that is no longer in use should be explicitly released by the `DXRelease()` function.

### ENUM_DX_FORMAT
This enumeration defines the pixel color formats available for textures.

| ID                                     | Value | Match in DXGI_FORMAT        |
| -------------------------------------- | ----- | --------------------------- |
| DX_FORMAT_UNKNOWN                      | 0     | DXGI_FORMAT_UNKNOWN         |
| DX_FORMAT_R32G32B32A32_TYPELESS        | 1     | DXGI_FORMAT_R32G32B32A32_TYPELESS |
| DX_FORMAT_R32G32B32A32_FLOAT           | 2     | DXGI_FORMAT_R32G32B32A32_FLOAT |
| DX_FORMAT_R32G32B32A32_UINT            | 3     | DXGI_FORMAT_R32G32B32A32_UINT |
| DX_FORMAT_R32G32B32A32_SINT            | 4     | DXGI_FORMAT_R32G32B32A32_SINT |
| DX_FORMAT_R32G32B32_TYPELESS           | 5     | DXGI_FORMAT_R32G32B32_TYPELESS |
| DX_FORMAT_R32G32B32_FLOAT              | 6     | DXGI_FORMAT_R32G32B32_FLOAT |
| DX_FORMAT_R32G32B32_UINT               | 7     | DXGI_FORMAT_R32G32B32_UINT  |
| DX_FORMAT_R32G32B32_SINT               | 8     | DXGI_FORMAT_R32G32B32_SINT  |
| DX_FORMAT_R16G16B16A16_TYPELESS        | 9     | DXGI_FORMAT_R16G16B16A16_TYPELESS |
| DX_FORMAT_R16G16B16A16_FLOAT           | 10    | DXGI_FORMAT_R16G16B16A16_FLOAT |
| DX_FORMAT_R16G16B16A16_UNORM           | 11    | DXGI_FORMAT_R16G16B16A16_UNORM |
| DX_FORMAT_R16G16B16A16_UINT            | 12    | DXGI_FORMAT_R16G16B16A16_UINT |
| DX_FORMAT_R16G16B16A16_SNORM           | 13    | DXGI_FORMAT_R16G16B16A16_SNORM |
| DX_FORMAT_R16G16B16A16_SINT            | 14    | DXGI_FORMAT_R16G16B16A16_SINT |
| DX_FORMAT_R32G32_TYPELESS              | 15    | DXGI_FORMAT_R32G32_TYPELESS |
| DX_FORMAT_R32G32_FLOAT                 | 16    | DXGI_FORMAT_R32G32_FLOAT    |
| DX_FORMAT_R32G32_UINT                  | 17    | DXGI_FORMAT_R32G32_UINT     |
| DX_FORMAT_R32G32_SINT                  | 18    | DXGI_FORMAT_R32G32_SINT     |
| DX_FORMAT_R32G8X24_TYPELESS            | 19    | DXGI_FORMAT_R32G8X24_TYPELESS |
| DX_FORMAT_D32_FLOAT_S8X24_UINT         | 20    | DXGI_FORMAT_D32_FLOAT_S8X24_UINT |
| DX_FORMAT_R32_FLOAT_X8X24_TYPELESS     | 21    | DXGI_FORMAT_R32_FLOAT_X8X24_TYPELESS |
| DX_FORMAT_X32_TYPELESS_G8X24_UINT      | 22    | DXGI_FORMAT_X32_TYPELESS_G8X24_UINT |
| DX_FORMAT_R10G10B10A2_TYPELESS         | 23    | DXGI_FORMAT_R10G10B10A2_TYPELESS |
| DX_FORMAT_R10G10B10A2_UNORM            | 24    | DXGI_FORMAT_R10G10B10A2_UNORM |
| DX_FORMAT_R10G10B10A2_UINT             | 25    | DXGI_FORMAT_R10G10B10A2_UINT |
| DX_FORMAT_R11G11B10_FLOAT              | 26    | DXGI_FORMAT_R11G11B10_FLOAT |
| DX_FORMAT_R8G8B8A8_TYPELESS            | 27    | DXGI_FORMAT_R8G8B8A8_TYPELESS |
| DX_FORMAT_R8G8B8A8_UNORM               | 28    | DXGI_FORMAT_R8G8B8A8_UNORM  |
| DX_FORMAT_R8G8B8A8_UNORM_SRGB          | 29    | DXGI_FORMAT_R8G8B8A8_UNORM_SRGB |
| DX_FORMAT_R8G8B8A8_UINT               | 30    | DXGI_FORMAT_R8G8B8A8_UINT   |
| DX_FORMAT_R8G8B8A8_SNORM               | 31    | DXGI_FORMAT_R8G8B8A8_SNORM  |
| DX_FORMAT_R8G8B8A8_SINT                | 32    | DXGI_FORMAT_R8G8B8A8_SINT   |
| DX_FORMAT_R16G16_TYPELESS              | 33    | DXGI_FORMAT_R16G16_TYPELESS |
| DX_FORMAT_R16G16_FLOAT                 | 34    | DXGI_FORMAT_R16G16_FLOAT    |
| DX_FORMAT_R16G16_UNORM                 | 35    | DXGI_FORMAT_R16G16_UNORM    |
| DX_FORMAT_R16G16_UINT                  | 36    | DXGI_FORMAT_R16G16_UINT     |
| DX_FORMAT_R16G16_SNORM                 | 37    | DXGI_FORMAT_R16G16_SNORM    |
| DX_FORMAT_R16G16_SINT                  | 38    | DXGI_FORMAT_R16G16_SINT     |
| DX_FORMAT_R32_TYPELESS                 | 39    | DXGI_FORMAT_R32_TYPELESS    |
| DX_FORMAT_D32_FLOAT                    | 40    | DXGI_FORMAT_D32_FLOAT       |
| DX_FORMAT_R32_FLOAT                    | 41    | DXGI_FORMAT_R32_FLOAT       |
| DX_FORMAT_R32_UINT                     | 42    | DXGI_FORMAT_R32_UINT        |
| DX_FORMAT_R32_SINT                     | 43    | DXGI_FORMAT_R32_SINT        |
| DX_FORMAT_R24G8_TYPELESS               | 44    | DXGI_FORMAT_R24G8_TYPELESS  |
| DX_FORMAT_D24_UNORM_S8_UINT            | 45    | DXGI_FORMAT_D24_UNORM_S8_UINT |
| DX_FORMAT_R24_UNORM_X8_TYPELESS        | 46    | DXGI_FORMAT_R24_UNORM_X8_TYPELESS |
| DX_FORMAT_X24_TYPELESS_G8_UINT         | 47    | DXGI_FORMAT_X24_TYPELESS_G8_UINT |
| DX_FORMAT_R8G8_TYPELESS                | 48    | DXGI_FORMAT_R8G8_TYPELESS   |
| DX_FORMAT_R8G8_UNORM                   | 49    | DXGI_FORMAT_R8G8_UNORM      |
| DX_FORMAT_R8G8_UINT                    | 50    | DXGI_FORMAT_R8G8_UINT       |
| DX_FORMAT_R8G8_SNORM                   | 51    | DXGI_FORMAT_R8G8_SNORM      |
| DX_FORMAT_R8G8_SINT                    | 52    | DXGI_FORMAT_R8G8_SINT       |
| DX_FORMAT_R16_TYPELESS                 | 53    | DXGI_FORMAT_R16_TYPELESS    |
| DX_FORMAT_R16_FLOAT                    | 54    | DXGI_FORMAT_R16_FLOAT       |
```

--------------------------------

### Get MetaTrader 5 Version in Python

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5version_py

Retrieves the MetaTrader 5 terminal version, build number, and release date using the `version()` function. This function returns a tuple containing this information or None if an error occurs. Errors can be checked using `last_error()`.

```python
import MetaTrader5 as mt5
import pandas as pd

# display data on the MetaTrader 5 package
print("MetaTrader5 package author: ", mt5.__author__)
print("MetaTrader5 package version: ", mt5.__version__)

# establish connection to the MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed, error code =", mt5.last_error())
    quit()

# display data on MetaTrader 5 version
print(mt5.version())

# display data on connection status, server name and trading account 'as is'
print(mt5.terminal_info())
print()

# get properties in the form of a dictionary
terminal_info_dict = mt5.terminal_info()._asdict()
# convert the dictionary into DataFrame and print
df = pd.DataFrame(list(terminal_info_dict.items()), columns=['property', 'value'])
print("terminal_info() as dataframe:")
print(df[:-1])

# shut down connection to the MetaTrader 5 terminal
mt5.shutdown()
```

--------------------------------

### Render Indexed Primitives using DXDrawIndexed in MQL5

Source: https://www.mql5.com/en/docs/directx/dxdrawindexed

The DXDrawIndexed function renders graphic primitives specified by an index buffer. It requires a valid graphic context, and the start index and count of primitives to render. Prerequisites include setting the vertex buffer and shaders.

```MQL5
bool DXDrawIndexed(
int context, // graphic context handle    
uint start=0, // first primitive index   
uint count=WHOLE_ARRAY // number of primitives   
);
```

--------------------------------

### MQL5 Initialization Event Handler: OnInit Function

Source: https://www.mql5.com/en/docs/basis/function/events

The OnInit() function serves as the Init event handler for Expert Advisors and indicators. It can have a void or int return type and must not have any parameters. A non-zero int return code signifies initialization failure.

```MQL5
void OnInit();
```

--------------------------------

### Get Market Depth Data with Python

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5marketbookget_py

This Python code snippet demonstrates how to connect to MetaTrader 5, subscribe to market depth updates for a symbol (e.g., 'EURUSD'), retrieve the market depth data using market_book_get, display it, and then release the subscription. It also shows how to access individual order details from the returned BookInfo tuple.

```python
import MetaTrader5 as mt5
import time

# display data on the MetaTrader 5 package
print("MetaTrader5 package author: ", mt5.__author__)
print("MetaTrader5 package version: ", mt5.__version__)
print("")

# establish connection to the MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed, error code =", mt5.last_error())
    # shut down connection to the MetaTrader 5 terminal
    mt5.shutdown()
    quit()

# subscribe to market depth updates for EURUSD (Depth of Market)
if mt5.market_book_add('EURUSD'):
    # get the market depth data 10 times in a loop
    for i in range(10):
        # get the market depth content (Depth of Market)
        items = mt5.market_book_get('EURUSD')
        # display the entire market depth 'as is' in a single string
        print(items)
        # now display each order separately for more clarity
        if items:
            for it in items:
                # order content
                print(it._asdict())
        # pause for 5 seconds before the next request of the market depth data
        time.sleep(5)
    # cancel the subscription to the market depth updates (Depth of Market)
    mt5.market_book_release('EURUSD')
else:
    print("mt5.market_book_add('EURUSD') failed, error code =", mt5.last_error())
```

--------------------------------

### Get Historical Deal Count using Python

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5historydealstotal_py

This Python code snippet demonstrates how to connect to the MetaTrader 5 terminal, retrieve the total number of deals within a specified date range using the `history_deals_total` function, and then disconnect.

```python
from datetime import datetime
import MetaTrader5 as mt5

# display data on the MetaTrader 5 package
print("MetaTrader5 package author: ",mt5.__author__)
print("MetaTrader5 package version: ",mt5.__version__)

# establish connection to MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed, error code =",mt5.last_error())
    quit()

# get the number of deals in history
from_date=datetime(2020,1,1)
to_date=datetime.now()
deals=mt5.history_deals_total(from_date, to_date)
if deals>0:
    print("Total deals=",deals)
else:
    print("Deals not found in history")

# shut down connection to the MetaTrader 5 terminal
mt5.shutdown()
```

--------------------------------

### Write to OpenCL Buffer from Matrix - MQL5

Source: https://www.mql5.com/en/docs/opencl/clbufferwrite

Writes the contents of a MQL5 matrix into an OpenCL buffer. Specifies the buffer handle and the starting offset in bytes within the buffer. Returns true if the write operation is successful, false otherwise. Supports matrix, matrixf, and matrixc types.

```mql5
uint CLBufferWrite(
int buffer, // a handle to the OpenCL buffer
uint buffer_offset, // an offset in the OpenCL buffer in bytes
matrix<T> &mat // the values matrix for writing to the buffer
);
```

--------------------------------

### Place Pending Order with TRADE_ACTION_PENDING in MQL5

Source: https://www.mql5.com/en/docs/constants/tradingconstants/enum_trade_request_actions

This MQL5 code example shows how to place a pending order (BUY_LIMIT, SELL_LIMIT, BUY_STOP, SELL_STOP) using the TRADE_ACTION_PENDING operation. It calculates the order price based on the current market price and a specified offset, normalizes it, and then sends the trade request. It includes input parameters for order type and a magic number.

```MQL5
#property description "Example of placing pending orders"
#property script_show_inputs
#define EXPERT_MAGIC 123456 // MagicNumber of the expert
input ENUM_ORDER_TYPE orderType = ORDER_TYPE_BUY_LIMIT; // order type
//+------------------------------------------------------------------+
//| Placing pending orders |
//+------------------------------------------------------------------+
void OnStart()
{
//--- declare and initialize the trade request and result of trade request
  MqlTradeRequest request = {};
  MqlTradeResult result = {};
//--- parameters to place a pending order
  request.action = TRADE_ACTION_PENDING; // type of trade operation
  request.symbol = Symbol(); // symbol
  request.volume = 0.1; // volume of 0.1 lot
  request.deviation = 2; // allowed deviation from the price
  request.magic = EXPERT_MAGIC; // MagicNumber of the order
  int offset = 50; // offset from the current price to place the order, in points
  double price;
  double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT); // value of point
  int digits = SymbolInfoInteger(_Symbol, SYMBOL_DIGITS); // number of decimal places (precision)
//--- checking the type of operation
  if (orderType == ORDER_TYPE_BUY_LIMIT)
  {
    request.type = ORDER_TYPE_BUY_LIMIT; // order type
    price = SymbolInfoDouble(Symbol(), SYMBOL_ASK) - offset * point; // price for opening
    request.price = NormalizeDouble(price, digits); // normalized opening price
  }
  else if (orderType == ORDER_TYPE_SELL_LIMIT)
  {
    request.type = ORDER_TYPE_SELL_LIMIT; // order type
    price = SymbolInfoDouble(Symbol(), SYMBOL_ASK) + offset * point; // price for opening
    request.price = NormalizeDouble(price, digits); // normalized opening price
  }
  else if (orderType == ORDER_TYPE_BUY_STOP)
  {
    request.type = ORDER_TYPE_BUY_STOP; // order type
    price = SymbolInfoDouble(Symbol(), SYMBOL_ASK) + offset * point; // price for opening
    request.price = NormalizeDouble(price, digits); // normalized opening price
  }
  else if (orderType == ORDER_TYPE_SELL_STOP)
  {
    request.type = ORDER_TYPE_SELL_STOP; // order type
    price = SymbolInfoDouble(Symbol(), SYMBOL_ASK) - offset * point; // price for opening
    request.price = NormalizeDouble(price, digits); // normalized opening price
  }
  else
    Alert("This example is only for placing pending orders"); // if not pending order is selected
//--- send the request
  if (!OrderSend(request, result))
    PrintFormat("OrderSend error %d", GetLastError()); // if unable to send the request, output the error code
//--- information about the operation
  PrintFormat("retcode=%u deal=%I64u order=%I64u", result.retcode, result.deal, result.order);
}
```

--------------------------------

### Get OpenCL Last Error Code (MQL5)

Source: https://www.mql5.com/en/docs/opencl

Retrieves the integer error code of the last OpenCL operation. The 'handle' parameter is ignored and can be set to zero. This function is crucial for diagnosing issues in OpenCL programs.

```MQL5
//--- the first 'handle' parameter is ignored when getting the last error code
intcode= (int)CLGetInfoInteger(0,CL_LAST_ERROR);
```

--------------------------------

### Create DirectX Buffer - MQL5

Source: https://www.mql5.com/en/docs/directx/dxbuffercreate

The DXBufferCreate function generates a buffer (vertex or index) for a given DirectX graphics context. It requires the context handle, buffer type, and an array containing the buffer data. Optional parameters specify the starting index and the number of elements to use from the data array. The function returns a handle to the created buffer or INVALID_HANDLE on error.

```mql5
int DXBufferCreate(
int context, // graphic context handle
ENUM_DX_BUFFER_TYPE buffer_type, // type of a created buffer
const void& data[], // buffer data
uint start=0, // initial index
uint count=WHOLE_ARRAY // number of elements
);
```

--------------------------------

### Python Integration: Get Total Orders with MetaTrader5

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5orderstotal_py

This snippet demonstrates how to connect to the MetaTrader 5 terminal using the Python 'MetaTrader5' library, retrieve the total number of active orders, and then disconnect. It includes error handling for initialization and displays the order count or a 'not found' message.

```python
import MetaTrader5 as mt5

# display data on the MetaTrader 5 package
print("MetaTrader5 package author: ", mt5.__author__)
print("MetaTrader5 package version: ", mt5.__version__)

# establish connection to MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed, error code =", mt5.last_error())
    quit()

# check the presence of active orders
orders = mt5.orders_total()
if orders > 0:
    print("Total orders=", orders)
else:
    print("Orders not found")

# shut down connection to the MetaTrader 5 terminal
mt5.shutdown()
```

--------------------------------

### MQL5 Get Account Integer Properties

Source: https://www.mql5.com/en/docs/account/accountinfointeger

This MQL5 code snippet demonstrates how to use the AccountInfoInteger function to retrieve and display various integer account properties. It checks trade permissions, account types, and StopOut mode settings.

```MQL5
void OnStart() {
//--- Show all the information available from the function AccountInfoInteger() 
printf("ACCOUNT_LOGIN = %d",AccountInfoInteger(ACCOUNT_LOGIN));
printf("ACCOUNT_LEVERAGE = %d",AccountInfoInteger(ACCOUNT_LEVERAGE));
bool thisAccountTradeAllowed=AccountInfoInteger(ACCOUNT_TRADE_ALLOWED);
bool EATradeAllowed=AccountInfoInteger(ACCOUNT_TRADE_EXPERT);
ENUM_ACCOUNT_TRADE_MODE tradeMode=(ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE);
ENUM_ACCOUNT_STOPOUT_MODE stopOutMode=(ENUM_ACCOUNT_STOPOUT_MODE)AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE);

//--- Inform about the possibility to perform a trade operation 
if(thisAccountTradeAllowed)
Print("Trade for this account is permitted");
else
Print("Trade for this account is prohibited!");

//--- Find out if it is possible to trade on this account by Expert Advisors 
if(EATradeAllowed)
Print("Trade by Expert Advisors is permitted for this account");
else
Print("Trade by Expert Advisors is prohibited for this account!");

//--- Find out the account type
switch(tradeMode)
{
case(ACCOUNT_TRADE_MODE_DEMO):
Print("This is a demo account");
break;
case(ACCOUNT_TRADE_MODE_CONTEST):
Print("This is a competition account");
break;
default:Print("This is a real account!");
}

//--- Find out the StopOut level setting mode
switch(stopOutMode)
{
case(ACCOUNT_STOPOUT_MODE_PERCENT):
Print("The StopOut level is specified percentage");
break;
default:Print("The StopOut level is specified in monetary terms");
}
}
```

--------------------------------

### MQL5: Avoiding Direct Equality Comparison of Real Numbers

Source: https://www.mql5.com/en/docs/basis/types/double

Explains why direct equality comparison (`==`) of floating-point numbers is unreliable due to binary representation inaccuracies. It provides an example where `1/3 + 4/3` does not exactly equal `5/3` when using floating-point arithmetic.

```MQL5
void OnStart()
{
//---
double three=3.0;
double x,y,z;
x=1/three;
y=4/three;
z=5/three;
if(x+y==z)
Print("1/3 + 4/3 == 5/3");
else
Print("1/3 + 4/3 != 5/3");
// Result: 1/3 + 4/3 != 5/3
}
```

--------------------------------

### Get DirectX Graphics Context Depth Buffer

Source: https://www.mql5.com/en/docs/directx/dxcontextcreate

Retrieves the current depth buffer content of a graphics context as a texture. Requires a valid context handle. The returned texture represents the depth information.

```MQL5
int DXContextGetDepth(
  int context_handle // handle of the graphic context
);

```

--------------------------------

### Get Symbol Integer Property (MQL5)

Source: https://www.mql5.com/en/docs/marketinformation/symbolinfointeger

This MQL5 function retrieves an integer property of a specified symbol. It can directly return the property value or return true/false indicating success and populate a reference variable with the property's value.

```MQL5
long SymbolInfoInteger(
string name, // symbol
ENUM_SYMBOL_INFO_INTEGER prop_id // identifier of a property

);

bool SymbolInfoInteger(
string name, // symbol
ENUM_SYMBOL_INFO_INTEGER prop_id, // identifier of a property
long& long_var // here we accept the property value
);

void OnTick()
{
//--- obtain spread from the symbol properties
bool spreadfloat=SymbolInfoInteger(Symbol(),SYMBOL_SPREAD_FLOAT);
string comm=StringFormat("Spread %s = %I64d points\r\n",
spreadfloat?"floating":"fixed",
SymbolInfoInteger(Symbol(),SYMBOL_SPREAD));
//--- now let's calculate the spread by ourselves
double ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
double bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
double spread=ask-bid;
int spread_points=(int)MathRound(spread/SymbolInfoDouble(Symbol(),SYMBOL_POINT));
comm=comm+"Calculated spread = "+(string)spread_points+" points";
Comment(comm);
}
```

--------------------------------

### Get History Orders Total (Python)

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5historyorderstotal_py

Retrieves the total count of orders in the trading history within a specified date range. Requires connection to the MetaTrader 5 terminal and returns an integer representing the number of orders.

```python
from datetime import datetime
import MetaTrader5 as mt5

# display data on the MetaTrader 5 package
print("MetaTrader5 package author: ",mt5.__author__)
print("MetaTrader5 package version: ",mt5.__version__)

# establish connection to MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed, error code =",mt5.last_error())
    quit()

# get the number of orders in history
from_date=datetime(2020,1,1)
to_date=datetime.now()
history_orders=mt5.history_orders_total(from_date, datetime.now())
if history_orders>0:
    print("Total history orders=",history_orders)
else:
    print("Orders not found in history")

# shut down connection to the MetaTrader 5 terminal
mt5.shutdown()
```

--------------------------------

### MQL5 OrderSend Function Example with Error Handling

Source: https://www.mql5.com/en/docs/constants/structures/mqltraderesult

Demonstrates how to use the OrderSend function in MQL5 and process the MqlTradeResult to handle various trade request outcomes. It includes specific error code handling for common issues like requotes, rejections, and invalid parameters.

```MQL5
//+------------------------------------------------------------------+
//| Sending a trade request with the result processing |
//+------------------------------------------------------------------+
bool MyOrderSend(MqlTradeRequest request,MqlTradeResult result)
{
//--- reset the last error code to zero
ResetLastError();
//--- send request
bool success=OrderSend(request,result);
//--- if the result fails - try to find out why
if(!success)
{
int answer=result.retcode;
Print("TradeLog: Trade request failed. Error = ",GetLastError());
switch(answer)
{
//--- requote
case 10004:
{
Print("TRADE_RETCODE_REQUOTE");
Print("request.price = ",request.price," result.ask = ",
result.ask," result.bid = ",result.bid);
break;
}
//--- order is not accepted by the server
case 10006:
{
Print("TRADE_RETCODE_REJECT");
Print("request.price = ",request.price," result.ask = ",
result.ask," result.bid = ",result.bid);
break;
}
//--- invalid price
case 10015:
{
Print("TRADE_RETCODE_INVALID_PRICE");
Print("request.price = ",request.price," result.ask = ",
result.ask," result.bid = ",result.bid);
break;
}
//--- invalid SL and/or TP
case 10016:
{
Print("TRADE_RETCODE_INVALID_STOPS");
Print("request.sl = ",request.sl," request.tp = ",request.tp);
Print("result.ask = ",result.ask," result.bid = ",result.bid);
break;
}
//--- invalid volume
case 10014:
{

```

--------------------------------

### Get Terminal Data Path in MQL5

Source: https://www.mql5.com/en/docs/runtime/resources

Provides MQL5 code to retrieve the path to the terminal's data folder. This is useful for locating sound files or other resources within the terminal's file structure. The function TerminalInfoString() is used with the TERMINAL_DATA_PATH parameter.

```MQL5
//--- Folder, in which terminal data are stored
string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);
```

--------------------------------

### Setting Indicator Plot Draw Start in MQL5

Source: https://www.mql5.com/en/docs/customind

This snippet shows how to use the PlotIndexSetInteger function in MQL5 to specify the first bar from which an indicator's data should be drawn. This is useful for indicators that require a certain number of initial bars for calculation.

```MQL5
//--- sets first bar from which index will be drawn
PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, 37);
```

--------------------------------

### Get Terminal Build and 64-bit Status (MQL5)

Source: https://www.mql5.com/en/docs/check/terminalinfodouble

This MQL5 script demonstrates how to retrieve the build number of the running MetaTrader 5 terminal and check if it is a 64-bit version using TerminalInfoInteger. The obtained information is then printed to the journal. It highlights the use of TerminalInfoInteger for retrieving integer properties of the terminal environment.

```MQL5
//+------------------------------------------------------------------+
//| Script program start function |
//+------------------------------------------------------------------+
void OnStart()
{
//--- get the build number of the running terminal and its "64-bit terminal" property
int build = TerminalInfoInteger(TERMINAL_BUILD);
bool x64 = TerminalInfoInteger(TERMINAL_X64);

//--- print the obtained terminal data in the journal
PrintFormat("MetaTrader 5 %s build %d", (x64 ? "x64" : "x32"), build);
/*
result:
MetaTrader 5 x64 build 4330
*/
}

```

--------------------------------

### MQL5 Structure with 4-Byte Alignment

Source: https://www.mql5.com/en/docs/basis/types/classes

Illustrates an MQL5 structure with explicit 4-byte alignment using 'pack(4)'. This example highlights how alignment affects the total size of the structure, introducing padding bytes to ensure members are aligned on 4-byte boundaries. It also shows the resulting size and member sizes.

```MQL5
//+------------------------------------------------------------------+
//| Script program start function |
//+------------------------------------------------------------------+
void OnStart()
{
//--- simple structure with the 4-byte alignment
struct Simple_Structure pack(4)
{
char c; // sizeof(char)=1
short s; // sizeof(short)=2
int i; // sizeof(int)=4
double d; // sizeof(double)=8
};

//--- declare a simple structure instance 
Simple_Structure s;

//--- display the size of each structure member
Print("sizeof(s.c)=",sizeof(s.c));
Print("sizeof(s.s)=",sizeof(s.s));
Print("sizeof(s.i)=",sizeof(s.i));
Print("sizeof(s.d)=",sizeof(s.d));

//--- make sure the size of POD structure is now not equal to the sum of its members' size
Print("sizeof(simple_structure)=",sizeof(simple_structure));
/*
Result:
sizeof(s.c)=1
sizeof(s.s)=2
sizeof(s.i)=4
sizeof(s.d)=8
sizeof(simple_structure)=16 // structure size has changed
*/
}
```

--------------------------------

### MQL5 Base Class Constructor with Initialization List

Source: https://www.mql5.com/en/docs/basis/types/classes

Demonstrates a base class `CFoo` in MQL5 with a constructor that utilizes an initialization list to set a string member `m_name`. The constructor prints the initialized name.

```MQL5
//+------------------------------------------------------------------+
//| Base class |
//+------------------------------------------------------------------+
class CFoo
{
string m_name;
public:
//--- A constructor with an initialization list
CFoo(string name) : m_name(name) { Print(m_name);}
};

```

--------------------------------

### Include Standard MQL5 Header File

Source: https://www.mql5.com/en/docs/basis/preprosessor/include

Demonstrates how to include a header file from the MQL5 standard include directory using angle brackets. The preprocessor searches only in the standard location.

```MQL5
#include <WinUser32.mqh>
```

--------------------------------

### Display Dataframe with Data using MQL5 in Python

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5copyratesfrom_py

This snippet demonstrates how to display financial data obtained from the MetaTrader5 package. It prints the dataframe in a raw format and then in a more readable, structured format. No external dependencies beyond the MetaTrader5 package are required.

```python
# display data
print("\nDisplay dataframe with data")
print(rates_frame)
```

--------------------------------

### Set Order Price, Take Profit, and Stop Loss in MQL5

Source: https://www.mql5.com/en/docs/constants/tradingconstants/enum_trade_request_actions

This code snippet calculates and sets the opening price, Take Profit (TP), and Stop Loss (SL) for different types of pending orders (BUY_LIMIT, SELL_LIMIT, BUY_STOP, SELL_STOP). It uses `SymbolInfoDouble` to get currentAsk/Bid prices and `NormalizeDouble` for price precision. The `OrderSend` function is then used to submit the order request.

```mql5
//--- setting the price level, Take Profit and Stop Loss of the order depending on its type  
if(type==ORDER_TYPE_BUY_LIMIT)  
{
  price = SymbolInfoDouble(Symbol(),SYMBOL_ASK)-offset*point;   
  request.tp = NormalizeDouble(price+offset*point,digits);  
  request.sl = NormalizeDouble(price-offset*point,digits);  
  request.price =NormalizeDouble(price,digits); // normalized opening price  
}
else if(type==ORDER_TYPE_SELL_LIMIT)  
{
  price = SymbolInfoDouble(Symbol(),SYMBOL_BID)+offset*point;   
  request.tp = NormalizeDouble(price-offset*point,digits);  
  request.sl = NormalizeDouble(price+offset*point,digits);  
  request.price =NormalizeDouble(price,digits); // normalized opening price  
}
else if(type==ORDER_TYPE_BUY_STOP)  
{
  price = SymbolInfoDouble(Symbol(),SYMBOL_BID)+offset*point;   
  request.tp = NormalizeDouble(price+offset*point,digits);  
  request.sl = NormalizeDouble(price-offset*point,digits);  
  request.price =NormalizeDouble(price,digits); // normalized opening price  
}
else if(type==ORDER_TYPE_SELL_STOP)  
{
  price = SymbolInfoDouble(Symbol(),SYMBOL_ASK)-offset*point;   
  request.tp = NormalizeDouble(price-offset*point,digits);  
  request.sl = NormalizeDouble(price+offset*point,digits);  
  request.price =NormalizeDouble(price,digits); // normalized opening price  
}
//--- send the request  
if(!OrderSend(request,result))
PrintFormat("OrderSend error %d",GetLastError()); // if unable to send the request, output the error code  
//--- information about the operation   
PrintFormat("retcode=%u deal=%I64u order=%I64u",result.retcode,result.deal,result.order);
//--- zeroing the request and result values  
ZeroMemory(request);
ZeroMemory(result);
}
}
}

```

--------------------------------

### MQL5: Fetch Bar Data with copy_rates_from_pos

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5copyratesfrompos_py

This Python snippet demonstrates how to use the MQL5 copy_rates_from_pos function to retrieve historical bar data. It initializes the MetaTrader 5 connection, fetches 10 daily bars for 'GBPUSD' starting from the current bar (index 0), and then shuts down the connection. The retrieved data is printed first as raw tuples and then as a formatted Pandas DataFrame.

```python
from datetime import datetime
import MetaTrader5 as mt5

# display data on the MetaTrader 5 package
print("MetaTrader5 package author: ", mt5.__author__)
print("MetaTrader5 package version: ", mt5.__version__)

# import the 'pandas' module for displaying data obtained in the tabular form
import pandas as pd
pd.set_option('display.max_columns', 500) # number of columns to be displayed
pd.set_option('display.width', 1500) # max table width to display

# establish connection to MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed, error code =", mt5.last_error())
    quit()

# get 10 GBPUSD D1 bars from the current day
rates = mt5.copy_rates_from_pos("GBPUSD", mt5.TIMEFRAME_D1, 0, 10)

# shut down connection to the MetaTrader 5 terminal
mt5.shutdown()

# display each element of obtained data in a new line
print("Display obtained data 'as is'")
for rate in rates:
    print(rate)

# create DataFrame out of the obtained data
rates_frame = pd.DataFrame(rates)
# convert time in seconds into the datetime format
rates_frame['time']=pd.to_datetime(rates_frame['time'], unit='s')

# display data
print("\nDisplay dataframe with data")
print(rates_frame)
```

--------------------------------

### Retrieve Ticks from MetaTrader 5 using Python

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5copyticksfrom_py

This Python code snippet demonstrates how to connect to the MetaTrader 5 terminal, retrieve tick data for a specific symbol and date range using `copy_ticks_from`, and display it. It also shows how to convert the received data into a pandas DataFrame for easier analysis. Ensure MetaTrader5 and pandas libraries are installed.

```python
from datetime import datetime
import MetaTrader5 as mt5
import pandas as pd
import pytz

# Display MetaTrader5 package information
print("MetaTrader5 package author: ", mt5.__author__)
print("MetaTrader5 package version: ", mt5.__version__)

# Set pandas display options
pd.set_option('display.max_columns', 500)
pd.set_option('display.width', 1500)

# Establish connection to MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed, error code =", mt5.last_error())
    quit()

# Set time zone to UTC
timezone = pytz.timezone("Etc/UTC")
# Create datetime object in UTC time zone
utc_from = datetime(2020, 1, 10, tzinfo=timezone)

# Request 100,000 EURUSD ticks starting from 2020-01-10 in UTC
ticks = mt5.copy_ticks_from("EURUSD", utc_from, 100000, mt5.COPY_TICKS_ALL)
print(f"Ticks received: {len(ticks)}")

# Shut down connection to the MetaTrader 5 terminal
mt5.shutdown()

# Display raw tick data
print("Display obtained ticks 'as is'")
count = 0
for tick in ticks:
    count += 1
    print(tick)
    if count >= 10:
        break

# Create a pandas DataFrame from the obtained data
ticks_frame = pd.DataFrame(ticks)
# Convert time in seconds to datetime format
ticks_frame['time'] = pd.to_datetime(ticks_frame['time'], unit='s')

print("\nDataFrame of ticks:")
print(ticks_frame.head())

```

--------------------------------

### Get Transaction Textual Description in MQL5

Source: https://www.mql5.com/en/docs/constants/structures/mqltradetransaction

This MQL5 helper function, `TransactionDescription`, generates a detailed string representation of an `MqlTradeTransaction` object. It includes information such as transaction type, symbol, deal ticket, order details, price, volume, and more.

```MQL5
//+------------------------------------------------------------------+
//| Returns transaction textual description |
//+------------------------------------------------------------------+
string TransactionDescription(const MqlTradeTransaction &trans)
{
//---    
string desc=EnumToString(trans.type)+"\r\n";
desc+="Symbol: "+trans.symbol+"\r\n";
desc+="Deal ticket: "+(string)trans.deal+"\r\n";
desc+="Deal type: "+EnumToString(trans.deal_type)+"\r\n";
desc+="Order ticket: "+(string)trans.order+"\r\n";
desc+="Order type: "+EnumToString(trans.order_type)+"\r\n";
desc+="Order state: "+EnumToString(trans.order_state)+"\r\n";
desc+="Order time type: "+EnumToString(trans.time_type)+"\r\n";
desc+="Order expiration: "+TimeToString(trans.time_expiration)+"\r\n";
desc+="Price: "+StringFormat("%G",trans.price)+"\r\n";
desc+="Price trigger: "+StringFormat("%G",trans.price_trigger)+"\r\n";
desc+="Stop Loss: "+StringFormat("%G",trans.price_sl)+"\r\n";
desc+="Take Profit: "+StringFormat("%G",trans.price_tp)+"\r\n";
desc+="Volume: "+StringFormat("%G",trans.volume)+"\r\n";
desc+="Position: "+(string)trans.position+"\r\n";
desc+="Position by: "+(string)trans.position_by+"\r\n";
//--- return the obtained string   
return desc;
}
//+------------------------------------------------------------------+
```

--------------------------------

### Write to OpenCL Buffer from Vector - MQL5

Source: https://www.mql5.com/en/docs/opencl/clbufferwrite

Writes the contents of a MQL5 vector into an OpenCL buffer. Requires the buffer handle and the starting offset in bytes within the buffer. Returns true upon successful write, false otherwise. Supports vector, vectorf, and vectorc types.

```mql5
uint CLBufferWrite(
int buffer, // a handle to the OpenCL buffer
uint buffer_offset, // an offset in the OpenCL buffer in bytes
vector<T> &vec // the values vector for writing to the buffer
);
```

--------------------------------

### Create OpenCL Program from Source

Source: https://www.mql5.com/en/docs/opencl/clprogramcreate

Creates an OpenCL program from a given source code string within a specified OpenCL context. Returns a handle to the program or -1 on error. Use GetLastError() for error details. Supports an overloaded version to capture compilation logs.

```MQL5
int CLProgramCreate(
int context, // Handle to an OpenCL context
const string source // Source code
);

int CLProgramCreate(
int context, // Handle to an OpenCL context
const string source, // Source code
string &build_log // A string for receiving the compilation log
);
```

--------------------------------

### MQL5 Class with Default Value Constructor and Copy Constructor

Source: https://www.mql5.com/en/docs/basis/types/classes

Illustrates a class 'CFoo' with a constructor that takes a parameter with a default value, which is not considered a default constructor. It also includes a copy constructor for creating new objects from existing ones. The example demonstrates various ways to instantiate objects of this class.

```MQL5
//+------------------------------------------------------------------+
//| A class with a default constructor |
//+------------------------------------------------------------------+
class CFoo
{
datetime m_call_time; // Time of the last object call
public:
//--- Constructor with a parameter that has a default value is not a default constructor
CFoo(const datetime t=0){m_call_time=t;};
//--- Copy constructor
CFoo(const CFoo &foo){m_call_time=foo.m_call_time;};

string ToString(){return(TimeToString(m_call_time,TIME_DATE|TIME_SECONDS));};
};
//+------------------------------------------------------------------+
//| Script program start function |
//+------------------------------------------------------------------+
void OnStart()
{
// CFoo foo; // This variant cannot be used - a default constructor is not set
//--- Possible options to create the CFoo object
CFoo foo1(TimeCurrent()); // An explicit call of a parametric constructor
CFoo foo2(); // An explicit call of a parametric constructor with a default parameter
CFoo foo3=D'2009.09.09'; // An implicit call of a parametric constructor
CFoo foo40(foo1); // An explicit call of a copy constructor
CFoo foo41=foo1; // An implicit call of a copy constructor
CFoo foo5; // An explicit call of a default constructor (if there is no default constructor, 
// then a parametric constructor with a default value is called)
//--- Possible options to receive CFoo pointers
CFoo *pfoo6=new CFoo(); // Dynamic creation of an object and receiving of a pointer to it
CFoo *pfoo7=new CFoo(TimeCurrent());// Another option of dynamic object creation
CFoo *pfoo8=GetPointer(foo1); // Now pfoo8 points to object foo1
CFoo *pfoo9=pfoo7; // pfoo9 and pfoo7 point to one and the same object
// CFoo foo_array[3]; // This option cannot be used - a default constructor is not specified
//--- Show the value of m_call_time

```

--------------------------------

### initialize() - MQL5 Python Integration

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5initialize_py

Establishes a connection with the MetaTrader 5 terminal. This function can be called in three ways: without parameters, specifying the terminal path, or specifying the terminal path along with login, password, server, timeout, and portable mode.

```APIDOC
## POST /initialize

### Description
Establishes a connection with the MetaTrader 5 terminal.

### Method
POST

### Endpoint
/initialize

### Parameters
#### Path Parameters
None

#### Query Parameters
None

#### Request Body
- **path** (string) - Optional - Path to the metatrader.exe or metatrader64.exe file. If not specified, the module attempts to find the executable file on its own.
- **login** (integer) - Optional - Trading account number. If not specified, the last trading account is used.
- **password** (string) - Optional - Trading account password. If not set, the password for a specified trading account saved in the terminal database is applied automatically.
- **server** (string) - Optional - Trade server name. If not set, the server for a specified trading account saved in the terminal database is applied automatically.
- **timeout** (integer) - Optional - Connection timeout in milliseconds. If not specified, the value of 60000 (60 seconds) is applied.
- **portable** (boolean) - Optional - Flag of the terminal launch in portable mode. If not specified, the value of False is used.

### Request Example
```json
{
  "path": "C:\\MetaTrader 5\\metatrader.exe",
  "login": 123456,
  "password": "mypassword",
  "server": "MyServer",
  "timeout": 30000,
  "portable": true
}
```

### Response
#### Success Response (200)
- **result** (boolean) - Returns True in case of successful connection to the MetaTrader 5 terminal, otherwise - False.

#### Response Example
```json
{
  "result": true
}
```

### Note
If required, the MetaTrader 5 terminal is launched to establish connection when executing the initialize() call.

### See also
shutdown, terminal_info, version
```

--------------------------------

### Retrieve EURAUD Tick Data in MQL5

Source: https://www.mql5.com/en/docs/python_metatrader5

This example demonstrates retrieving tick data for the EURAUD currency pair using the `euraud_ticks` function in MQL5. It fetches a specified number of ticks and returns them as tuples containing timestamp, bid, ask, last, volume, time_msc, flag, and volume_real.

```mql5
euraud_ticks( 1000 )
(1580209200, 1.63412, 1.63437, 0., 0, 1580209200067, 130, 0.)
(1580209200, 1.63416, 1.63437, 0., 0, 1580209200785, 130, 0.)
(1580209201, 1.63415, 1.63437, 0., 0, 1580209201980, 130, 0.)
(1580209202, 1.63419, 1.63445, 0., 0, 1580209202192, 134, 0.)
(1580209203, 1.6342, 1.63445, 0., 0, 1580209203004, 130, 0.)
(1580209203, 1.63419, 1.63445, 0., 0, 1580209203487, 130, 0.)
(1580209203, 1.6342, 1.63445, 0., 0, 1580209203694, 130, 0.)
(1580209203, 1.63419, 1.63445, 0., 0, 1580209203990, 130, 0.)
(1580209204, 1.63421, 1.63445, 0., 0, 1580209204194, 130, 0.)
(1580209204, 1.63425, 1.63445, 0., 0, 1580209204392, 130, 0.)
```

--------------------------------

### Retrieve AUDUSD Tick Data in MQL5

Source: https://www.mql5.com/en/docs/python_metatrader5

This example shows how to fetch tick data for the AUDUSD currency pair using the `audusd_ticks` function in MQL5. It retrieves a specified number of ticks, returning data that includes timestamp, bid, ask, last, volume, time_msc, flag, and volume_real.

```mql5
audusd_ticks( 40449 )
(1580122800, 0.67858, 0.67868, 0., 0, 1580122800244, 130, 0.)
(1580122800, 0.67858, 0.67867, 0., 0, 1580122800429, 4, 0.)
(1580122800, 0.67858, 0.67865, 0., 0, 1580122800817, 4, 0.)
(1580122801, 0.67858, 0.67866, 0., 0, 1580122801618, 4, 0.)
(1580122802, 0.67858, 0.67865, 0., 0, 1580122802928, 4, 0.)
(1580122809, 0.67855, 0.67865, 0., 0, 1580122809526, 130, 0.)
(1580122809, 0.67855, 0.67864, 0., 0, 1580122809699, 4, 0.)
(1580122813, 0.67855, 0.67863, 0., 0, 1580122813576, 4, 0.)
(1580122815, 0.67856, 0.67863, 0., 0, 1580122815190, 130, 0.)
(1580122815, 0.67855, 0.67863, 0., 0, 1580122815479, 130, 0.)
```

--------------------------------

### Python: Get Symbols Excluding Specific Strings

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5symbolsget_py

Fetches financial symbols from the MetaTrader 5 terminal, excluding those whose names contain specified strings (USD, EUR, JPY, GBP) using negation in the group filter. Requires the MetaTrader5 package.

```python
import MetaTrader5 as mt5

# establish connection to the MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed, error code =", mt5.last_error())
    quit()

# get symbols whose names do not contain USD, EUR, JPY and GBP
group_symbols = mt5.symbols_get(group="*,!*USD*,!*EUR*,!*JPY*,!*GBP*")
print('len(*,!*USD*,!*EUR*,!*JPY*,!*GBP*):', len(group_symbols))
for s in group_symbols:
    print(s.name, ":", s)

```

--------------------------------

### Python: Get historical deals by date range and symbol group

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5historydealsget_py

This snippet demonstrates how to retrieve historical trading deals using the `history_deals_get` function from the MetaTrader5 package. It specifies a date range and filters deals based on symbol names containing 'GBP'. Error handling and output formatting are included. Requires the MetaTrader5, datetime, and pandas libraries.

```python
import MetaTrader5 as mt5
from datetime import datetime
import pandas as pd

pd.set_option('display.max_columns', 500) # number of columns to be displayed
pd.set_option('display.width', 1500) # max table width to display

# display data on the MetaTrader 5 package
print("MetaTrader5 package author: ",mt5.__author__)
print("MetaTrader5 package version: ",mt5.__version__)
print()

# establish connection to the MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed, error code =",mt5.last_error())
    quit()

# get the number of deals in history
from_date=datetime(2020,1,1)
to_date=datetime.now()

# get deals for symbols whose names contain "GBP" within a specified interval
deals=mt5.history_deals_get(from_date, to_date, group="*GBP*")
if deals==None:
    print("No deals with group=\"*USD*\", error code=",mt5.last_error())
elif len(deals)> 0:
    print("history_deals_get({}, {}, group=\"*GBP*\")={}".format(from_date,to_date,len(deals)))

# get deals for symbols whose names contain neither "EUR" nor "GBP"
deals = mt5.history_deals_get(from_date, to_date, group="*,!*EUR*,!*GBP*")
if deals == None:
    print("No deals, error code={}".format(mt5.last_error()))
elif len(deals) > 0:
    print("history_deals_get(from_date, to_date, group=\"*,!*EUR*,!*GBP*\") =", len(deals))

# display all obtained deals 'as is'
for deal in deals:
    print(" ",deal)
print()
```

--------------------------------

### MQL5: Create Graphical Label with ObjectCreate

Source: https://www.mql5.com/en/docs/runtime/resources

An MQL5 Expert Advisor demonstrating the creation of a graphical label (OBJ_BITMAP_LABEL). It initializes the label, sets its position, and assigns different BMP images for pressed and unpressed states using ObjectSetString. The code includes error checking for object creation and image assignment, and ensures the chart is redrawn.

```MQL5
string label_name="currency_label"; // name of the OBJ_BITMAP_LABEL object 
string euro ="\Images\euro.bmp"; // path to the file terminal_data_directory\MQL5\Images\euro.bmp 
string dollar ="\Images\dollar.bmp"; // path to the file terminal_data_directory\MQL5\Images\dollar.bmp 

//+------------------------------------------------------------------+
//| Expert initialization function |
//+------------------------------------------------------------------+
int OnInit()
{
//--- create a button OBJ_BITMAP_LABEL, if it hasn't been created yet
if(ObjectFind(0,label_name)<0)
{
//--- trying to create object OBJ_BITMAP_LABEL
bool created=ObjectCreate(0,label_name,OBJ_BITMAP_LABEL,0,0,0);
if(created)
{
//--- link the button to the left upper corner of the chart
ObjectSetInteger(0,label_name,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
//--- now set up the object properties
ObjectSetInteger(0,label_name,OBJPROP_XDISTANCE,100);
ObjectSetInteger(0,label_name,OBJPROP_YDISTANCE,50);
//--- reset the code of the last error to 0
ResetLastError();
//--- download a picture to indicate the "Pressed" state of the button
bool set=ObjectSetString(0,label_name,OBJPROP_BMPFILE,0,euro);
//--- test the result
if(!set)
{
PrintFormat("Failed to download image from file %s. Error code %d",euro,GetLastError());
}
ResetLastError();
//--- download a picture to indicate the "Unpressed" state of the button
set=ObjectSetString(0,label_name,OBJPROP_BMPFILE,1,dollar);

if(!set)
{
PrintFormat("Failed to download image from file %s. Error code %d",dollar,GetLastError());
}
//--- send a command for a chart to refresh so that the button appears immediately without a tick
ChartRedraw(0);
}
else
{
//--- failed to create an object, notify
PrintFormat("Failed to create object OBJ_BITMAP_LABEL. Error code %d",GetLastError());
}
}
//---
return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//--- delete an object from a chart
ObjectDelete(0,label_name);
}
```

--------------------------------

### Histogram Calculation and Plotting Example - MQL5

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/noncentralbeta

This MQL5 code demonstrates how to calculate and plot a histogram from a sample of random numbers, comparing it with the theoretical probability density function of the noncentral beta distribution. It includes functions for calculating histogram data and plotting using the CGraphic class.

```MQL5
#include <Graphics\Graphic.mqh>
#include <Math\Stat\NoncentralBeta.mqh>
#include <Math\Stat\Math.mqh>

#property script_show_inputs

//--- input parameters
input double a_par=2; // the first parameter of beta distribution (shape1)
input double b_par=5; // the second parameter of beta distribution (shape2)
input double l_par=1; // noncentrality parameter (lambda)

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   //--- hide the price chart
   ChartSetInteger(0,CHART_SHOW,false);
   
   //--- initialize the random number generator
   MathSrand(GetTickCount());
   
   //--- generate a sample of the random variable
   long chart=0;
   string name="GraphicNormal";
   int n=1000000; // the number of values in the sample
   int ncells=53; // the number of intervals in the histogram
   double x[]; // centers of the histogram intervals
   double y[]; // the number of values from the sample falling within the interval
   double data[]; // sample of random values
   double max,min; // the maximum and minimum values in the sample
   
   //--- obtain a sample from the noncentral beta distribution
   MathRandomNoncentralBeta(a_par,b_par,l_par,n,data);
   
   //--- calculate the data to plot the histogram
   CalculateHistogramArray(data,x,y,max,min,ncells);
   
   //--- obtain the sequence boundaries and the step for plotting the theoretical curve
   double step;
   GetMaxMinStepValues(max,min,step);
   step=MathMin(step,(max-min)/ncells);
   
   //--- obtain the theoretically calculated data at the interval of [min,max]
   double x2[];
   double y2[];
   MathSequence(min,max,step,x2);
   MathProbabilityDensityNoncentralBeta(x2,a_par,b_par,l_par,false,y2);
   
   //--- set the scale
   double theor_max=y2[ArrayMaximum(y2)];
   double sample_max=y[ArrayMaximum(y)];
   double k=sample_max/theor_max;
   for(int i=0; i<ncells; i++)
      y[i]/=k;
      
   //--- output charts
   CGraphic graphic;
   if(ObjectFind(chart,name)<0)
      graphic.Create(chart,name,0,0,0,780,380);
   else
      graphic.Attach(chart,name);
      
   graphic.BackgroundMain(StringFormat("Noncentral Beta distribution alpha=%G beta=%G lambda=%G",
                           a_par,b_par,l_par));
   graphic.BackgroundMainSize(16);
   
   //--- plot all curves
   graphic.CurveAdd(x,y,CURVE_HISTOGRAM,"Sample").HistogramWidth(6);
   //--- and now plot the theoretical curve of the distribution density
   graphic.CurveAdd(x2,y2,CURVE_LINES,"Theory");
   graphic.CurvePlotAll();
   
   //--- plot all curves
   graphic.Update();
}
//+------------------------------------------------------------------+
//| Calculate frequencies for data set                               |
//+------------------------------------------------------------------+
bool CalculateHistogramArray(const double &data[],double &intervals[],double &frequency[],
                             double &maxv,double &minv,const int cells=10)
{
   if(cells<=1) return (false);
   int size=ArraySize(data);
   if(size<cells*10) return (false);
   
   minv=data[ArrayMinimum(data)];
   maxv=data[ArrayMaximum(data)];
   double range=maxv-minv;
   double width=range/cells;
   if(width==0) return false;
   
   ArrayResize(intervals,cells);
   ArrayResize(frequency,cells);
   
   //--- define the interval centers
   for(int i=0; i<cells; i++)
      {
      intervals[i]=minv+(i+0.5)*width;
      frequency[i]=0;
      }
      
   //--- fill the frequencies of falling within the interval
   for(int i=0; i<size; i++)
      {
      int ind=int((data[i]-minv)/width);
      if(ind>=cells) ind=cells-1;
      frequency[ind]++;
      }
      
   return (true);
}

```

--------------------------------

### Get Last MQL5 Error Code

Source: https://www.mql5.com/en/docs/check/getlasterror

The GetLastError() function returns the value of the last error that occurred during the execution of an MQL5 program. It's crucial for debugging and error handling. The error code is not reset after the call, requiring ResetLastError() for explicit reset.

```MQL5
//+------------------------------------------------------------------+
//| Script program start function |
//+------------------------------------------------------------------+
void OnStart()
{
MqlRates rates[1]={}; // display the current bar data here

//--- intentionally call a function with inappropriate parameters
int res=CopyRates(NULL, PERIOD_CURRENT, 0, 2, rates);
if(res!=2)
PrintFormat("CopyRates() returned %d. LastError %d", res, GetLastError());

//--- reset the last error code before copying the current bar data to the MqlRates structure
ResetLastError();
//--- if the function does not work correctly, the error code will differ from 0
CopyRates(NULL, PERIOD_CURRENT, 0, 1, rates);
Print("CopyRates() error ", GetLastError());

//--- print the array of obtained values
ArrayPrint(rates);
}
```

--------------------------------

### Create DirectX Shader (MQL5)

Source: https://www.mql5.com/en/docs/directx/dxshadercreate

Creates a shader of a specified type (vertex, geometry, or pixel) using HLSL 5 source code. Requires a valid graphics context handle and specifies the entry point for the shader. Compilation errors are returned in a string.

```MQL5
int DXShaderCreate(
  int context, // graphic context handle
  ENUM_DX_SHADER_TYPE shader_type, // shader type
  const string source, // shader source code
  const string entry_point, // entry point
  string& compile_error // string for receiving compiler messages
);
```

--------------------------------

### MQL5: Get and Print Calendar Values (Method 1)

Source: https://www.mql5.com/en/docs/constants/structures/mqlcalendar

This MQL5 code demonstrates the first method for checking and retrieving calendar event values. It appears to format and potentially process the values before printing them. The output includes detailed information about each event, such as ID, event ID, time, period, revision, actual value, previous value, revised previous value, and forecast value.

```mql5
The first method to check and get calendar values
[id] [event_id] [time] [period] [revision] [actual_value] [prev_value] [revised_prev_value] [forecast_value] [impact_type]
[0] 144520 999500001 2021.01.04 12:00:00 2020.12.01 00:00:00 3 55.20000 55.50000 nan 55.50000 2
[1] 144338 999520001 2021.01.04 23:30:00 2020.12.29 00:00:00 0 143.10000 143.90000 nan nan 0
[2] 147462 999010020 2021.01.04 23:45:00 1970.01.01 00:00:00 0 nan nan nan nan 0
[3] 111618 999010018 2021.01.05 12:00:00 2020.11.01 00:00:00 0 11.00000 10.50000 nan 11.00000 0
[4] 111619 999010019 2021.01.05 12:00:00 2020.11.01 00:00:00 0 3.10000 3.10000 3.20000 3.10000 0
```

--------------------------------

### MQL5 Indicator: OnCalculate Function Logic

Source: https://www.mql5.com/en/docs/basis/function/events

This MQL5 code defines a custom indicator that demonstrates the OnCalculate function. It retrieves the total number of bars, prints bar information, and returns the rates_total for the next calculation cycle. It utilizes built-in MQL5 functions for indicator setup and data retrieval.

```MQL5
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 1
//---- plot Line
#property indicator_label1 "Line"
#property indicator_type1 DRAW_LINE
#property indicator_color1 clrDarkBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
//--- indicator buffers
double LineBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
SetIndexBuffer(0,LineBuffer,INDICATOR_DATA);
//---
return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
const int prev_calculated,
const datetime& time[],
const double& open[],
const double& high[],
const double& low[],
const double& close[],
const long& tick_volume[],
const long& volume[],
const int& spread[])
{
//--- Get the number of bars available for the current symbol and chart period
int bars=Bars(Symbol(),0);
Print("Bars = ",bars,", rates_total = ",rates_total,", prev_calculated = ",prev_calculated);
Print("time[0] = ",time[0]," time[rates_total-1] = ",time[rates_total-1]);
//--- return value of prev_calculated for next call
return(rates_total);
}
//+------------------------------------------------------------------+
```

--------------------------------

### Get Symbol Double Property (MQL5)

Source: https://www.mql5.com/en/docs/marketinformation/symbolinfodouble

Retrieves a double-precision property of a specified symbol. This variant directly returns the property value. It takes the symbol name and a property identifier (ENUM_SYMBOL_INFO_DOUBLE) as input. Returns the property value on success, or a specific value indicating failure.

```MQL5
double SymbolInfoDouble(
string name, // symbol
ENUM_SYMBOL_INFO_DOUBLE prop_id // identifier of the property
);
```

--------------------------------

### Get Total Symbols in MetaTrader 5 using Python

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5symbolstotal_py

Retrieves the total number of financial instruments available in the MetaTrader 5 terminal, including custom and disabled ones. Requires the MetaTrader5 package. Returns an integer representing the count, or an error message if initialization fails.

```python
import MetaTrader5 as mt5

# display data on the MetaTrader 5 package
print("MetaTrader5 package author: ", mt5.__author__)
print("MetaTrader5 package version: ", mt5.__version__)

# establish connection to the MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed, error code =", mt5.last_error())
    quit()

# get the number of financial instruments
symbols = mt5.symbols_total()
if symbols > 0:
    print("Total symbols =", symbols)
else:
    print("symbols not found")

# shut down connection to the MetaTrader 5 terminal
mt5.shutdown()
```

--------------------------------

### MQL5: Set DirectX Buffer for Rendering (DXBufferSet)

Source: https://www.mql5.com/en/docs/directx/dxbufferset

The DXBufferSet function in MQL5 is used to set either a vertex or an index buffer for the current rendering operation. It requires a graphics context handle and the buffer handle, along with optional parameters for the starting index and the number of elements to use. This function is a prerequisite for rendering commands like DXDraw().

```mql5
bool DXBufferSet(
int context, // graphic context handle
int buffer, // vertex or index buffer handle
uint start=0, // initial index
uint count=WHOLE_ARRAY // number of elements
);
```

--------------------------------

### MQL5: Closing Positions with OrderSend

Source: https://www.mql5.com/en/docs/constants/tradingconstants/enum_trade_request_actions

Provides an MQL5 code example for closing all open positions associated with a specific MagicNumber using the OrderSend() function. It iterates through open positions, checks for the matching MagicNumber, and prepares a trade request to close them. Error handling and position details are included.

```MQL5
#define EXPERT_MAGIC 123456 // MagicNumber of the expert
//+------------------------------------------------------------------+
//| Closing all positions |
//+------------------------------------------------------------------+
void OnStart()
{
//--- declare and initialize the trade request and result of trade request
MqlTradeRequest request;
MqlTradeResult result;
int total=PositionsTotal(); // number of open positions   
//--- iterate over all open positions  
for(int i=total-1; i>=0; i--)
{
//--- parameters of the order  
ulong position_ticket=PositionGetTicket(i); // ticket of the position  
string position_symbol=PositionGetString(POSITION_SYMBOL); // symbol   
int digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS); // number of decimal places  
ulong magic=PositionGetInteger(POSITION_MAGIC); // MagicNumber of the position  
double volume=PositionGetDouble(POSITION_VOLUME); // volume of the position  
ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE); // type of the position  
//--- output information about the position  
PrintFormat("#%I64u %s %s %.2f %s [%I64d]",
position_ticket,
position_symbol,
EnumToString(type),
volume,
DoubleToString(PositionGetDouble(POSITION_PRICE_OPEN),digits),
magic);
//--- if the MagicNumber matches  
if(magic==EXPERT_MAGIC)
{
//--- zeroing the request and result values  
ZeroMemory(request);
ZeroMemory(result);
//--- setting the operation parameters  
```

--------------------------------

### Get Symbol String Properties with MQL5

Source: https://www.mql5.com/en/docs/marketinformation/symbolinfostring

This MQL5 code snippet demonstrates how to use the SymbolInfoString function to retrieve various string properties of a given symbol, such as base currency, profit currency, margin currency, and a textual description. It then formats and prints this information to the journal. Ensure the SYMBOL_NAME is valid and available in Market Watch.

```MQL5
#define SYMBOL_NAME "USDJPY" 
  
//+------------------------------------------------------------------+
//| Script program start function |
//+------------------------------------------------------------------+
void OnStart() 
{
//--- get string data for SYMBOL_NAME symbol 
string currency_base = SymbolInfoString(SYMBOL_NAME, SYMBOL_CURRENCY_BASE); // Base currency of the symbol 
string currency_profit = SymbolInfoString(SYMBOL_NAME, SYMBOL_CURRENCY_PROFIT); // Profit currency 
string currency_margin = SymbolInfoString(SYMBOL_NAME, SYMBOL_CURRENCY_MARGIN); // Margin currency 
string symbol_descript = SymbolInfoString(SYMBOL_NAME, SYMBOL_DESCRIPTION); // String description of the symbol 
 
//--- create a message text with the obtained data 
string text=StringFormat("Symbol %s:\n"+
"- Currency Base: %s\n"+
"- Currensy Profit: %s\n"+
"- Currency Margin: %s\n"+
"- Symbol Description: %s", 
SYMBOL_NAME, currency_base, 
currency_profit, currency_margin, 
symbol_descript);
 
//--- send the obtained data to the journal 
Print(text);
/* 
Symbol USDJPY: 
- Currency Base: USD 
- Currensy Profit: JPY 
- Currency Margin: USD 
- Symbol Description: US Dollar vs Yen 
*/ 
}

```

--------------------------------

### Get Bollinger Bands Indicator Handle (MQL5)

Source: https://www.mql5.com/en/docs/indicators/ibands

The iBands function retrieves a handle to the Bollinger Bands® technical indicator. It requires parameters specifying the symbol, timeframe, indicator periods, shift, deviation, and applied price. Failure to obtain a handle results in INVALID_HANDLE.

```mql5
int iBands(
   string symbol,           // symbol name
   ENUM_TIMEFRAMES period,  // period
   int    bands_period,     // period for average line calculation
   int    bands_shift,      // horizontal shift of the indicator
   double deviation,        // number of standard deviations
   ENUM_APPLIED_PRICE applied_price // type of price or handle
);

```

--------------------------------

### Initialize MetaTrader 5 Connection in Python

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5initialize_py

Establishes a connection to the MetaTrader 5 terminal using provided account credentials. It checks for successful initialization and prints terminal information upon connection. Dependencies include the 'MetaTrader5' library. This function can be called with or without explicit path, login, password, server, timeout, and portable mode parameters.

```python
import MetaTrader5 as mt5

# display data on the MetaTrader 5 package
print("MetaTrader5 package author: ",mt5.__author__)
print("MetaTrader5 package version: ",mt5.__version__)

# establish MetaTrader 5 connection to a specified trading account
if not mt5.initialize(login=25115284, server="MetaQuotes-Demo",password="4zatlbqx"):
    print("initialize() failed, error code =",mt5.last_error())
    quit()

# display data on connection status, server name and trading account
print(mt5.terminal_info())
# display data on MetaTrader 5 version
print(mt5.version())

# shut down connection to the MetaTrader 5 terminal
mt5.shutdown()
```

--------------------------------

### Get Trade Request Textual Description in MQL5

Source: https://www.mql5.com/en/docs/constants/structures/mqltradetransaction

This MQL5 function, `RequestDescription`, provides a detailed string summary of an `MqlTradeRequest` object. It includes information about the action, symbol, magic number, order details, price, deviation, stop loss, take profit, volume, and comment.

```MQL5
//+------------------------------------------------------------------+
//| Returns the trade request textual description |
//+------------------------------------------------------------------+
string RequestDescription(const MqlTradeRequest &request)
{
//---   
string desc=EnumToString(request.action)+"\r\n";
desc+="Symbol: "+request.symbol+"\r\n";
desc+="Magic Number: "+StringFormat("%d",request.magic)+"\r\n";
desc+="Order ticket: "+(string)request.order+"\r\n";
desc+="Order type: "+EnumToString(request.type)+"\r\n";
desc+="Order filling: "+EnumToString(request.type_filling)+"\r\n";
desc+="Order time type: "+EnumToString(request.type_time)+"\r\n";
desc+="Order expiration: "+TimeToString(request.expiration)+"\r\n";
desc+="Price: "+StringFormat("%G",request.price)+"\r\n";
desc+="Deviation points: "+StringFormat("%G",request.deviation)+"\r\n";
desc+="Stop Loss: "+StringFormat("%G",request.sl)+"\r\n";
desc+="Take Profit: "+StringFormat("%G",request.tp)+"\r\n";
desc+="Stop Limit: "+StringFormat("%G",request.stoplimit)+"\r\n";
desc+="Volume: "+StringFormat("%G",request.volume)+"\r\n";
desc+="Comment: "+request.comment+"\r\n";
//--- return the obtained string   
return desc;
}

```

--------------------------------

### MQL5 OnCalculate for Single Data Buffer

Source: https://www.mql5.com/en/docs/basis/function/events

This form of OnCalculate() is designed for indicators that utilize a single data buffer, such as a Custom Moving Average. It receives the total number of rates, previously calculated bars, the starting index for significant data, and the price array to perform calculations.

```MQL5
int OnCalculate (const int rates_total, // size of the price[] array 
const int prev_calculated, // bars handled on a previous call 
const int begin, // where the significant data start from 
const double& price[] // array to calculate 
);
```

--------------------------------

### MQL5: CLExecute for Single Kernel Launch

Source: https://www.mql5.com/en/docs/opencl/clexecute

This MQL5 function executes a single OpenCL kernel. It takes a handle to the OpenCL kernel as input. This is the simplest form of CLExecute, suitable for basic kernel operations.

```mql5
bool CLExecute(
int kernel // Handle to the kernel of an OpenCL program
);
```

--------------------------------

### Include OpenCL Program as String Resource in MQL5

Source: https://www.mql5.com/en/docs/runtime/resources

This snippet demonstrates how to include an OpenCL program from a separate .cl file as a string resource within an MQL5 program. This is useful for managing larger OpenCL codebases. It requires the 'seascape.cl' file to be present in the project's resources. The output is a string variable `cl_program` that can be further processed.

```MQL5
#resource "seascape.cl" as string cl_program

int context;
if((cl_program=CLProgramCreate(context,cl_program)!=INVALID_HANDLE)
{
//--- perform further actions with an OpenCL program
}
```

--------------------------------

### MQL5 Function to Get Relative Program Path

Source: https://www.mql5.com/en/docs/runtime/resources

This MQL5 function, GetRelativeProgramPath(), is designed to determine the correct relative path for an MQL5 program, whether it's running independently or included as a resource within another program. It parses the absolute program path to construct a path relative to the MQL5 directory or its subdirectories.

```MQL5
string GetRelativeProgramPath()
{
int pos2;
//--- get the absolute path to the application
string path=MQLInfoString(MQL_PROGRAM_PATH);
//--- find the position of "\MQL5\" substring
int pos =StringFind(path,"\\MQL5\\");
//--- substring not found - error
if(pos<0)
return(NULL);
//--- skip "\MQL5" directory
pos+=5;
//--- skip extra '\' symbols
while(StringGetCharacter(path,pos+1)=='\')
pos++;
//--- if this is a resource, return the path relative to MQL5 directory
if(StringFind(path,"::",pos)>=0)
return(StringSubstr(path,pos));
//--- find a separator for the first MQL5 subdirectory (for example, MQL5\Indicators)
//--- if not found, return the path relative to MQL5 directory
if((pos2=StringFind(path,"\\",pos+1))<0)
return(StringSubstr(path,pos));
//--- return the path relative to the subdirectory (for example, MQL5\Indicators)
return(StringSubstr(path,pos2+1));
}
```

--------------------------------

### MQL5: Get Account Information using AccountInfoDouble

Source: https://www.mql5.com/en/docs/account/accountinfodouble

This MQL5 code snippet demonstrates how to use the AccountInfoDouble function to retrieve and print various double-precision account properties such as balance, credit, profit, equity, and margin details. It utilizes the printf function for output and relies on the ENUM_ACCOUNT_INFO_DOUBLE enumeration for property identification.

```MQL5
void OnStart()   
{
//--- Show all the information available from the function AccountInfoDouble()   
printf("ACCOUNT_BALANCE = %G",AccountInfoDouble(ACCOUNT_BALANCE));   
printf("ACCOUNT_CREDIT = %G",AccountInfoDouble(ACCOUNT_CREDIT));   
printf("ACCOUNT_PROFIT = %G",AccountInfoDouble(ACCOUNT_PROFIT));   
printf("ACCOUNT_EQUITY = %G",AccountInfoDouble(ACCOUNT_EQUITY));   
printf("ACCOUNT_MARGIN = %G",AccountInfoDouble(ACCOUNT_MARGIN));   
printf("ACCOUNT_MARGIN_FREE = %G",AccountInfoDouble(ACCOUNT_MARGIN_FREE));   
printf("ACCOUNT_MARGIN_LEVEL = %G",AccountInfoDouble(ACCOUNT_MARGIN_LEVEL));   
printf("ACCOUNT_MARGIN_SO_CALL = %G",AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL));   
printf("ACCOUNT_MARGIN_SO_SO = %G",AccountInfoDouble(ACCOUNT_MARGIN_SO_SO));   
}
```

--------------------------------

### Python: Get Last Error from MetaTrader5

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5lasterror_py

This Python snippet demonstrates how to use the `last_error()` function from the `MetaTrader5` library. It's typically used after a function call that might fail, like `initialize()`, to retrieve specific error information. The function returns a tuple containing the error code and its description.

```python
import MetaTrader5 as mt5

# display data on the MetaTrader 5 package
print("MetaTrader5 package author: ", mt5.__author__)
print("MetaTrader5 package version: ", mt5.__version__)

# establish connection to the MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed, error code =", mt5.last_error())
    quit()

# shut down connection to the MetaTrader 5 terminal
mt5.shutdown()
```

--------------------------------

### Fetch EURUSD H4 Bars from Specific Date using Python

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5copyratesfrom_py

This Python code snippet demonstrates how to connect to the MetaTrader 5 terminal, set the timezone to UTC, and use the copy_rates_from function to retrieve 10 bars of EURUSD H4 data starting from January 10, 2020. The retrieved data is then printed and converted into a pandas DataFrame for easier analysis.

```python
from datetime import datetime
import MetaTrader5 as mt5
import pandas as pd
import pytz

# display data on the MetaTrader 5 package
print("MetaTrader5 package author: ",mt5.__author__)
print("MetaTrader5 package version: ",mt5.__version__)

# import the 'pandas' module for displaying data obtained in the tabular form
pd.set_option('display.max_columns', 500) # number of columns to be displayed
pd.set_option('display.width', 1500) # max table width to display

# establish connection to MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed, error code =", mt5.last_error())
    quit()

# set time zone to UTC
timezone = pytz.timezone("Etc/UTC")
# create 'datetime' object in UTC time zone to avoid the implementation of a local time zone offset
utc_from = datetime(2020, 1, 10, tzinfo=timezone)

# get 10 EURUSD H4 bars starting from 01.10.2020 in UTC time zone
rates = mt5.copy_rates_from("EURUSD", mt5.TIMEFRAME_H4, utc_from, 10)

# shut down connection to the MetaTrader 5 terminal
mt5.shutdown()

# display each element of obtained data in a new line
print("Display obtained data 'as is'")
for rate in rates:
    print(rate)

# create DataFrame out of the obtained data
rates_frame = pd.DataFrame(rates)
# convert time in seconds into the datetime format
rates_frame['time']=pd.to_datetime(rates_frame['time'], unit='s')
```

--------------------------------

### MQL5: Handling Invalid Real Numbers (Infinity and NaN)

Source: https://www.mql5.com/en/docs/basis/types/double

Demonstrates how mathematical operations in MQL5 can result in invalid real numbers, such as negative infinity or NaN (Not a Number). It shows an example using `MathArcsin(2.0)` which results in an invalid number and mentions `MathIsValidNumber()` for checking.

```MQL5
double abnormal = MathArcsin(2.0);
Print("MathArcsin(2.0) =",abnormal);
// Result: MathArcsin(2.0) = -1.#IND
```

--------------------------------

### Define and Use Local Resource in MQL5

Source: https://www.mql5.com/en/docs/runtime/resources

This snippet demonstrates how to declare a resource (e.g., an image file) within an MQL5 script and then use it locally. The resource path is specified relative to the script's directory.

```MQL5
#resource "\\Files\\triangle.bmp"  
//--- using the resource in the script   
ObjectSetString(0,my_bitmap_name,OBJPROP_BMPFILE,0,"::Files\\triangle.bmp");
```

--------------------------------

### MQL5 SymbolSelect Example: Add and Remove Symbol

Source: https://www.mql5.com/en/docs/marketinformation/symbolselect

This MQL5 script demonstrates how to use the SymbolSelect function to add a symbol to the Market Watch window and then remove it. It also includes checks using SymbolExist and SymbolIndex to verify the symbol's presence and retrieve its index. The script handles potential errors during the selection and deselection process.

```MQL5
#define SYMBOL_NAME "GBPHKD"   
  
//+------------------------------------------------------------------+
//| Script program start function |
//+------------------------------------------------------------------+
void OnStart()   
{
//--- check for the presence of a symbol in the lists, if not found, report it and complete the work   
bool custom = false;
if(!SymbolExist(SYMBOL_NAME, custom))
{
PrintFormat("'%s' symbol not found in the lists", SYMBOL_NAME);
return;
}
  
//--- add a symbol to the Market Watch window   
ResetLastError();   
if(!SymbolSelect(SYMBOL_NAME, true))
{
Print("SymbolSelect() failed. Error ", GetLastError());
return;
}
//--- if a symbol is successfully added to the list, get its index in the Market Watch window and send the result to the journal   
int index = SymbolIndex(SYMBOL_NAME);
PrintFormat("The '%s' symbol has been added to the MarketWatch list. Symbol index in the list: %d", SYMBOL_NAME, index);
  
//--- now remove the symbol from the Market Watch window   
ResetLastError();   
if(!SymbolSelect(SYMBOL_NAME, false))
{
Print("SymbolSelect() failed. Error ", GetLastError());
return;
}
//--- if a symbol is successfully removed from the list, its index in the Market Watch window is -1, send the deletion result to the journal   
index = SymbolIndex(SYMBOL_NAME);
PrintFormat("The '%s' symbol has been removed from the MarketWatch list. Symbol index in the list: %d", SYMBOL_NAME, index);
  
/*   
result:   
The 'GBPHKD' symbol has been added to the MarketWatch list. Symbol index in the list: 12   
The 'GBPHKD' symbol has been removed from the MarketWatch list. Symbol index in the list: -1   
*/   
}
//+------------------------------------------------------------------+
//| Return the symbol index in the Market Watch symbol list |
//+------------------------------------------------------------------+
int SymbolIndex(const string symbol)
{
int total = SymbolsTotal(true);
for(int i=0; i<total; i++)
{
string name = SymbolName(i, true);
if(name == symbol)
return i;
}
return(WRONG_VALUE);
}
```

--------------------------------

### DXInputCreate

Source: https://www.mql5.com/en/docs/directx/dxinputcreate

Creates shader inputs for a given graphic context.

```APIDOC
## DXInputCreate

### Description
Creates shader inputs for a specified graphic context and input size.

### Method
`DXInputCreate`

### Parameters
#### Path Parameters
None

#### Query Parameters
None

#### Request Body
This function does not use a request body.

### Request Example
```
int shader_input_handle = DXInputCreate(graphic_context_handle, input_data_size);
```

### Response
#### Success Response (200)
- **Return Value** (int) - The handle for the created shader inputs. Returns `INVALID_HANDLE` on error.

#### Response Example
```
// Successful creation
int shader_input_handle = 101; 

// Error case
int shader_input_handle = -1; // INVALID_HANDLE
```

### Error Handling
- Call `GetLastError()` to retrieve the specific error code if `INVALID_HANDLE` is returned.
- Ensure the created handle is released using `DXRelease()` when no longer needed.
```

--------------------------------

### Get Symbol Count using SymbolsTotal in MQL5

Source: https://www.mql5.com/en/docs/marketinformation/symbolstotal

The SymbolsTotal function in MQL5 retrieves the number of available trading symbols. It accepts a boolean parameter 'selected' to filter between all server symbols or only those present in the Market Watch window. The function returns an integer representing the count.

```MQL5
//+------------------------------------------------------------------+
//| Script program start function |
//+------------------------------------------------------------------+
void OnStart()
{
//--- get the number of available symbols
int total = SymbolsTotal(false); // all symbols on the server
int selected = SymbolsTotal(true); // all symbols added to the Market Watch window

//--- send the obtained data to the journal
PrintFormat("Number of available symbols on the server: %d\n" +
"Number of available symbols selected in MarketWatch: %d", total, selected);
/*
result:
Number of available symbols on the server: 140
Number of available symbols selected in MarketWatch: 11
*/
}
```

--------------------------------

### MQL5 Default and Parametric Constructor Implementations

Source: https://www.mql5.com/en/docs/basis/types/classes

Provides the implementation for the default and parametric constructors of the 'MyDateClass'. The default constructor initializes members with the current system time, while the parametric constructor sets the hour, minute, and second, defaulting other date members to the current date.

```MQL5
//+------------------------------------------------------------------+
//| Default constructor |
//+------------------------------------------------------------------+
MyDateClass::MyDateClass(void)
{
//---
MqlDateTime mdt;
datetime t=TimeCurrent(mdt);
m_year=mdt.year;
m_month=mdt.mon;
m_day=mdt.day;
m_hour=mdt.hour;
m_minute=mdt.min;
m_second=mdt.sec;
Print(__FUNCTION__);
}
//+------------------------------------------------------------------+
//| Parametric constructor |
//+------------------------------------------------------------------+
MyDateClass::MyDateClass(int h,int m,int s)
{
MqlDateTime mdt;
datetime t=TimeCurrent(mdt);
m_year=mdt.year;
m_month=mdt.mon;
m_day=mdt.day;
m_hour=h;
m_minute=m;
m_second=s;
Print(__FUNCTION__);
}

```

--------------------------------

### MQL5: Get and Print Calendar Values (Method 2)

Source: https://www.mql5.com/en/docs/constants/structures/mqlcalendar

This MQL5 code illustrates the second method for checking and retrieving calendar event values. Similar to the first method, it outputs formatted data for each event, including ID, event ID, time, period, revision, actual value, previous value, revised previous value, and forecast value. The output format suggests data processing or validation has occurred.

```mql5
The second method to check and get calendar values
[id] [event_id] [time] [period] [revision] [actual_value] [prev_value] [revised_prev_value] [forecast_value] [impact_type]
[0] 144520 999500001 2021.01.04 12:00:00 2020.12.01 00:00:00 3 55.20000 55.50000 nan 55.50000 2
[1] 144338 999520001 2021.01.04 23:30:00 2020.12.29 00:00:00 0 143.10000 143.90000 nan nan 0
[2] 147462 999010020 2021.01.04 23:45:00 1970.01.01 00:00:00 0 nan nan nan nan 0
[3] 111618 999010018 2021.01.05 12:00:00 2020.11.01 00:00:00 0 11.00000 10.50000 nan 11.00000 0
[4] 111619 999010019 2021.01.05 12:00:00 2020.11.01 00:00:00 0 3.10000 3.10000 3.20000 3.10000 0
```

--------------------------------

### Fetch Ticks in Date Range with Python (MetaTrader5)

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5copyticksrange_py

Demonstrates how to use the `copy_ticks_range` function from the MetaTrader5 Python package to retrieve tick data for a specific financial instrument within a given date range. It includes initializing the connection, setting time zones, requesting ticks, and processing the returned data using pandas. The example highlights the importance of UTC time zone handling.

```python
from datetime import datetime
import MetaTrader5 as mt5
import pandas as pd
import pytz

# display data on the MetaTrader 5 package
print("MetaTrader5 package author: ",mt5.__author__)
print("MetaTrader5 package version: ",mt5.__version__)

# import the 'pandas' module for displaying data obtained in the tabular form
pd.set_option('display.max_columns', 500) # number of columns to be displayed
pd.set_option('display.width', 1500) # max table width to display

# establish connection to MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed, error code =",mt5.last_error())
    quit()

# set time zone to UTC
timezone = pytz.timezone("Etc/UTC")
# create 'datetime' objects in UTC time zone to avoid the implementation of a local time zone offset
utc_from = datetime(2020, 1, 10, tzinfo=timezone)
utc_to = datetime(2020, 1, 11, tzinfo=timezone)

# request AUDUSD ticks within 11.01.2020 - 11.01.2020
ticks = mt5.copy_ticks_range("AUDUSD", utc_from, utc_to, mt5.COPY_TICKS_ALL)
print("Ticks received:",len(ticks))

# shut down connection to the MetaTrader 5 terminal
mt5.shutdown()

# display data on each tick on a new line
print("Display obtained ticks 'as is'")
count = 0
for tick in ticks:
    count+=1
    print(tick)
    if count >= 10:
        break

# create DataFrame out of the obtained data
ticks_frame = pd.DataFrame(ticks)
# convert time in seconds into the datetime format
ticks_frame['time']=pd.to_datetime(ticks_frame['time'], unit='s')
```

--------------------------------

### Connect to MetaTrader 5 and Fetch Data

Source: https://www.mql5.com/en/docs/python_metatrader5

Demonstrates how to initialize a connection to MetaTrader 5 using the MetaTrader5 Python module, retrieve terminal information and version, fetch tick data and historical rates for various currency pairs, and shut down the connection.

```python
from datetime import datetime
import matplotlib.pyplot as plt
import pandas as pd
from pandas.plotting import register_matplotlib_converters
register_matplotlib_converters()
import MetaTrader5 as mt5

# connect to MetaTrader 5
if not mt5.initialize():
    print("initialize() failed")
    mt5.shutdown()

# request connection status and parameters
print(mt5.terminal_info())
# get data on MetaTrader 5 version
print(mt5.version())

# request 1000 ticks from EURAUD
euraud_ticks = mt5.copy_ticks_from("EURAUD", datetime(2020,1,28,13), 1000, mt5.COPY_TICKS_ALL)
# request ticks from AUDUSD within 2019.04.01 13:00 - 2019.04.02 13:00
audusd_ticks = mt5.copy_ticks_range("AUDUSD", datetime(2020,1,27,13), datetime(2020,1,28,13), mt5.COPY_TICKS_ALL)

# get bars from different symbols in a number of ways
eurusd_rates = mt5.copy_rates_from("EURUSD", mt5.TIMEFRAME_M1, datetime(2020,1,28,13), 1000)
eurgbp_rates = mt5.copy_rates_from_pos("EURGBP", mt5.TIMEFRAME_M1, 0, 1000)
eurcad_rates = mt5.copy_rates_range("EURCAD", mt5.TIMEFRAME_M1, datetime(2020,1,27,13), datetime(2020,1,28,13))

# shut down connection to MetaTrader 5
mt5.shutdown()

#DATA
print('euraud_ticks(', len(euraud_ticks), ')')
for val in euraud_ticks[:10]: print(val)

print('audusd_ticks(', len(audusd_ticks), ')')
for val in audusd_ticks[:10]: print(val)

print('eurusd_rates(', len(eurusd_rates), ')')
for val in eurusd_rates[:10]: print(val)

print('eurgbp_rates(', len(eurgbp_rates), ')')
for val in eurgbp_rates[:10]: print(val)

print('eurcad_rates(', len(eurcad_rates), ')')
for val in eurcad_rates[:10]: print(val)

```

--------------------------------

### Set Shader Inputs with DXInputSet (MQL5)

Source: https://www.mql5.com/en/docs/directx/dxinputset

The DXInputSet function in MQL5 is used to set data for shader inputs. It requires a graphic context handle and the data to be set. Successful execution returns true, otherwise false. Related functions include DXInputCreate and DXShaderCreate.

```MQL5
bool DXInputSet(
int input, // graphic context handle   
const void& data // data for setting    
);
```

--------------------------------

### Manipulate and Display Bitmap Resource in MQL5

Source: https://www.mql5.com/en/docs/runtime/resources

Demonstrates modifying a bitmap resource (adding a red stripe) and creating graphical objects using both direct resource addressing and resource variables. It also highlights the limitation of direct addressing after resource variable declaration.

```MQL5
//+------------------------------------------------------------------+
//| Script program start function |
//+------------------------------------------------------------------+
void OnStart()
{
//--- output the size of the image [width, height] stored in euro resource variable
Print(ArrayRange(euro,1),", ",ArrayRange(euro,0));
//--- change the image in euro - draw the red horizontal stripe in the middle
for(int x=0;x<ArrayRange(euro,1);x++)
    euro[ArrayRange(euro,1)/2][x]=0xFFFF0000;
//--- create the graphical resource using the resource variable
ResourceCreate("euro_icon",euro,ArrayRange(euro,1),ArrayRange(euro,0),0,0,ArrayRange(euro,1),COLOR_FORMAT_ARGB_NORMALIZE);
//--- create the Euro graphical label object, to which the image from the euro_icon resource will be set
Image("Euro","::euro_icon",10,40);
//--- another method of applying the resource, we cannot draw do it
Image("USD","::Images\dollar.bmp",15+ArrayRange(euro,1),40);
//--- direct method of addressing the euro.bmp resource is unavailable since it has already been declared via the euro resource variable
Image("E2","::Images\euro.bmp",20+ArrayRange(euro,1)*2,40); // execution time error is to occur
}

```

--------------------------------

### Get Symbol Tick Data with MQL5 SymbolInfoTick

Source: https://www.mql5.com/en/docs/marketinformation/symbolinfotick

This MQL5 code snippet demonstrates how to use the SymbolInfoTick function to retrieve the latest price data for a given symbol. It checks for errors and prints the retrieved tick information to the journal. The function requires the symbol name and an MqlTick structure reference as input. It returns true on success and false on failure.

```MQL5
#define SYMBOL_NAME "EURUSD"   
  
//+------------------------------------------------------------------+
//| Script program start function |
//+------------------------------------------------------------------+
void OnStart()   
{
//--- declare an array with the MqlTick structure type of dimension 1   
MqlTick tick[1]={};   
  
//--- get the latest prices for the SYMBOL_NAME symbol into the MqlTick structure   
if(!SymbolInfoTick(SYMBOL_NAME, tick[0]))   
{
Print("SymbolInfoTick() failed. Error ", GetLastError());   
return;
}
  
//--- send the obtained data to the journal   
PrintFormat("Latest price data for the '%s' symbol:", SYMBOL_NAME);
ArrayPrint(tick);
/*   
result:   
Latest price data for the 'EURUSD' symbol:   
[time] [bid] [ask] [last] [volume] [time_msc] [flags] [volume_real]   
[0] 2024.05.17 23:58:54 1.08685 1.08695 0.0000 0 1715990334319 6 0.00000   
*/   
}

```

--------------------------------

### Include and Use Custom Indicator Resource in MQL5 EA

Source: https://www.mql5.com/en/docs/runtime/resources

This MQL5 code snippet demonstrates how to include a custom indicator (SampleIndicator.ex5) as a resource within an Expert Advisor (SampleEA.mq5). The #resource directive embeds the indicator, and iCustom() is used in OnInit() to obtain a handle to it. Error handling for handle creation is included.

```MQL5
#resource "\\Indicators\\SampleIndicator.ex5"
int handle_ind;
//+------------------------------------------------------------------+
//| Expert initialization function |
//+------------------------------------------------------------------+
int OnInit()
{
//--- 
handle_ind=iCustom(_Symbol,_Period,"::Indicators\\SampleIndicator.ex5");
if(handle_ind==INVALID_HANDLE)
{
Print("Expert: iCustom call: Error code=",GetLastError());
return(INIT_FAILED);
}
//--- ...
return(INIT_SUCCEEDED);
}
```

--------------------------------

### Utilize Declared Resources in MQL5

Source: https://www.mql5.com/en/docs/runtime/resources

Demonstrates how to use resources previously declared with the #resource directive. A special prefix '::' is added before the resource name (path without leading backslash) when referencing it in functions like ObjectSetString or PlaySound. Some object properties, like OBJPROP_BMPFILE, may become read-only after being set from a resource.

```MQL5
ObjectSetString(0,bitmap_name,OBJPROP_BMPFILE,0,"::Images\\\euro.bmp");
ObjectSetString(0,my_bitmap,OBJPROP_BMPFILE,0,"::picture.bmp");
set=ObjectSetString(0,bitmap_label,OBJPROP_BMPFILE,1,"::Files\\\Pictures\\\good.bmp");
PlaySound("::Files\\\Demo.wav");
PlaySound("::Sounds\\\thrill.wav")
```

--------------------------------

### MQL5 OpenCL Device Information Retrieval

Source: https://www.mql5.com/en/docs/opencl/clprogramcreate

This snippet shows how to retrieve device information for OpenCL.

```MQL5
CLGetDeviceInfo
```

--------------------------------

### Create DirectX Shader Inputs (MQL5)

Source: https://www.mql5.com/en/docs/directx/dxinputcreate

Creates shader inputs for DirectX rendering within MQL5. It requires a valid graphic context handle obtained from DXContextCreate and the size in bytes of the input data structure. The function returns a handle to the created shader inputs or INVALID_HANDLE on failure. Remember to release the handle using DXRelease when it's no longer needed.

```MQL5
int DXInputCreate(
int context, // graphic context handle
uint input_size // size of inputs in bytes
);
```

--------------------------------

### Connect to MetaTrader 5 Account using Python

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5login_py

This snippet demonstrates how to initialize the MetaTrader 5 connection, log in to a trading account using account number and optional password/server, retrieve account information, and shut down the connection.

```python
import MetaTrader5 as mt5

# display data on the MetaTrader 5 package
print("MetaTrader5 package author: ",mt5.__author__)
print("MetaTrader5 package version: ",mt5.__version__)

# establish connection to the MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed, error code =",mt5.last_error())
    quit()

# display data on MetaTrader 5 version
print(mt5.version())

# connect to the trade account without specifying a password and a server
account=17221085
authorized=mt5.login(account) # the terminal database password is applied if connection data is set to be remembered
if authorized:
    print("connected to account #{}".format(account))
else:
    print("failed to connect at account #{}, error code: {}".format(account, mt5.last_error()))

# now connect to another trading account specifying the password
account=25115284
authorized=mt5.login(account, password="gqrtz0lbdm")
if authorized:
    # display trading account data 'as is'
    print(mt5.account_info())
    # display trading account data in the form of a list
    print("Show account_info()._asdict():")
    account_info_dict = mt5.account_info()._asdict()
    for prop in account_info_dict:
        print(" {}={}".format(prop, account_info_dict[prop]))
else:
    print("failed to connect at account #{}, error code: {}".format(account, mt5.last_error()))

# shut down connection to the MetaTrader 5 terminal
mt5.shutdown()
```

--------------------------------

### MQL5: CLExecute with Local Work Group Specification

Source: https://www.mql5.com/en/docs/opencl/clexecute

This MQL5 function launches multiple kernel copies with detailed task space description and local work group size. It includes parameters for kernel handle, task space dimensions, offsets, total tasks, and the size of local task subsets within groups.

```mql5
bool CLExecute(
int kernel, // Handle to the kernel of an OpenCL program
uint work_dim, // Dimension of the tasks space
const uint& global_work_offset[], // Initial offset in the tasks space
const uint& global_work_size[], // Total number of tasks
const uint& local_work_size[] // Number of tasks in the local group
);
```

--------------------------------

### MQL5: Get Calendar Event Values Without Checks (Method 3 Output)

Source: https://www.mql5.com/en/docs/constants/structures/mqlcalendar

This MQL5 code output represents the results from the third method of retrieving calendar event values, specifically designed to fetch data without performing explicit checks. It displays a detailed list of events, including their IDs, event IDs, times, periods, revisions, actual values, previous values, revised previous values, forecast values, and impact types.

```mql5
The third method to get calendar values - without checks
[id] [event_id] [time] [period] [revision] [actual_value] [prev_value] [revised_prev_value] [forecast_value] [impact_type]
[0] 144520 999500001 2021.01.04 12:00:00 2020.12.01 00:00:00 3 55.20000 55.50000 nan 55.50000 2
[1] 144338 999520001 2021.01.04 23:30:00 2020.12.29 00:00:00 0 143.10000 143.90000 nan nan 0
[2] 147462 999010020 2021.01.04 23:45:00 1970.01.01 00:00:00 0 nan nan nan nan 0
[3] 111618 999010018 2021.01.05 12:00:00 2020.11.01 00:00:00 0 11.00000 10.50000 nan 11.00000 0
[4] 111619 999010019 2021.01.05 12:00:00 2020.11.01 00:00:00 0 3.10000 3.10000 3.20000 3.10000 0
```

--------------------------------

### Create Bitmap Label Object in MQL5

Source: https://www.mql5.com/en/docs/runtime/resources

Function to create an OBJ_BITMAP_LABEL object using a specified resource file path. It sets the object's position and bitmap file.

```MQL5
//+------------------------------------------------------------------+
//| OBJ_BITMAP_LABEL object creation function using the resource |
//+------------------------------------------------------------------+
void Image(string name,string rc,int x,int y)
{
ObjectCreate(0,name,OBJ_BITMAP_LABEL,0,0,0);
ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
ObjectSetString(0,name,OBJPROP_BMPFILE,rc);
}

```

--------------------------------

### Modify SL/TP of Open Position with TRADE_ACTION_SLTP in MQL5

Source: https://www.mql5.com/en/docs/constants/tradingconstants/enum_trade_request_actions

This MQL5 code snippet is designed to modify the Stop Loss (SL) and Take Profit (TP) levels of open positions using the TRADE_ACTION_SLTP operation. It iterates through all open positions, retrieves their details, and prepares a trade request to update the SL and TP values. Note: The actual modification logic for SL/TP values is not fully implemented in the provided snippet, only the iteration and request setup.

```MQL5
#define EXPERT_MAGIC 123456 // MagicNumber of the expert
//+------------------------------------------------------------------+
//| Modification of Stop Loss and Take Profit of position |
//+------------------------------------------------------------------+
void OnStart()
{
//--- declare and initialize the trade request and result of trade request
  MqlTradeRequest request;
  MqlTradeResult result;
  int total = PositionsTotal(); // number of open positions
//--- iterate over all open positions
  for (int i = 0; i < total; i++)
  {
//--- parameters of the order
    ulong position_ticket = PositionGetTicket(i); // ticket of the position
    string position_symbol = PositionGetString(POSITION_SYMBOL); // symbol
    int digits = (int)SymbolInfoInteger(position_symbol, SYMBOL_DIGITS); // number of decimal places
    // ... further logic to set request.action = TRADE_ACTION_SLTP and update SL/TP values ...
```

--------------------------------

### DXShaderCreate

Source: https://www.mql5.com/en/docs/directx/dxshadercreate

Creates a shader of a specified type within a given DirectX context. It takes the context handle, shader type, source code, entry point, and an output parameter for compilation errors.

```APIDOC
## DXShaderCreate

### Description
Creates a shader of a specified type.

### Method
`int DXShaderCreate(int context, ENUM_DX_SHADER_TYPE shader_type, const string source, const string entry_point, string& compile_error);`

### Endpoint
N/A (This is a function call, not a REST endpoint)

### Parameters
#### Path Parameters
None

#### Query Parameters
None

#### Request Body
None

### Parameters

- **context** (int) - in - Handle for a graphic context created in DXContextCreate().
- **shader_type** (ENUM_DX_SHADER_TYPE) - out - The value from the ENUM_DX_SHADER_TYPE enumeration.
- **source** (const string) - in - Shader source code in HLSL 5.
- **entry_point** (const string) - in - Entry point – function name in a source code.
- **compile_error** (string&) - in - String for receiving compilation errors.

### Request Example
```c++
// Example usage (conceptual)
int shaderHandle = DXShaderCreate(contextHandle, DX_SHADER_VERTEX, "// Vertex shader source...", "main", errorMessage);
```

### Response
#### Success Response (int)
Returns a handle for the created shader. INVALID_HANDLE in case of an error.

#### Response Example
```json
{
  "shaderHandle": 123 // Example handle value
}
```

#### Error Response
If an error occurs, `INVALID_HANDLE` is returned. `GetLastError()` can be called to retrieve the error code.

### Notes
- A created handle that is no longer in use should be explicitly released by the `DXRelease()` function.

### ENUM_DX_SHADER_TYPE

| ID | Value | Description |
|---|---|---|
| DX_SHADER_VERTEX | 0 | Vertex shader |
| DX_SHADER_GEOMETRY | 1 | Geometry shader |
| DX_SHADER_PIXEL | 2 | Pixel shader |
```

--------------------------------

### Declare Resources with #resource Directive (MQL5)

Source: https://www.mql5.com/en/docs/runtime/resources

Declares external files as resources within an MQL5 program. The compiler searches for these resources based on the provided path. Path length is limited to 63 characters, and certain characters/substrings are forbidden. Resources can be located relative to the terminal data directory or the source file directory.

```MQL5
#resource "\\\Images\\\euro.bmp"
#resource "picture.bmp"
#resource "Resource\\\map.bmp"
#resource "\\\Files\\\Pictures\\\good.bmp"
#resource "\\\Files\\\Demo.wav"
#resource "\\\Sounds\\\thrill.wav"
```

--------------------------------

### MQL5: Declaring and Initializing Floating-Point Variables

Source: https://www.mql5.com/en/docs/basis/types/double

Demonstrates the declaration and initialization of `double` and `float` variables with various literal values, including decimal and integer representations. It highlights the difference in precision and memory usage between `double` and `float`.

```MQL5
double a=12.111;
double b=-956.1007;
float c =0.0001;
float d =16;
```

--------------------------------

### MQL5 Script to Instantiate Derived Class Object

Source: https://www.mql5.com/en/docs/basis/types/classes

A simple MQL5 script program that demonstrates the execution flow by creating an instance of the `CBar` class. This will trigger the constructors of `CBar`, its parent `CFoo`, and its member `m_member`.

```MQL5
//+------------------------------------------------------------------+
//| Script program start function |
//+------------------------------------------------------------------+
void OnStart()
{
CBar bar;
}

```

--------------------------------

### Retrieve OpenCL Device Information using CLGetDeviceInfo

Source: https://www.mql5.com/en/docs/opencl/clgetdeviceinfo

This MQL5 code snippet demonstrates how to use the CLGetDeviceInfo function to retrieve various properties of OpenCL devices. It iterates through available devices, creates an OpenCL context, and then fetches device name and vendor information. Error handling for context creation is included.

```MQL5
void OnStart()
{
//---
int dCount= CLGetInfoInteger(0,CL_DEVICE_COUNT);
for(int i = 0; i<dCount; i++)
{
int clCtx=CLContextCreate(i);
if(clCtx == -1)
Print("ERROR in CLContextCreate");
string device;
CLGetInfoString(clCtx,CL_DEVICE_NAME,device);
Print(i,": ",device);
uchar data[1024];
uint size;
CLGetDeviceInfo(clCtx,CL_DEVICE_VENDOR,data,size);
Print("size = ",size);
string str=CharArrayToString(data);
Print(str);
}
}
//---
```

--------------------------------

### Fetch and Display All Deals as DataFrame

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5historydealsget_py

This code snippet fetches all available deal data using the `metaTrader5` package and displays it as a pandas DataFrame. It requires the `pandas` and `metaTrader5` libraries. The output is a formatted table of deals, with the 'time' column converted to datetime objects.

```python
# display these deals as a table using pandas.DataFrame
df=pd.DataFrame(list(deals),columns=deals[0]._asdict().keys())
df['time'] = pd.to_datetime(df['time'], unit='s')
print(df)
print("")
```

--------------------------------

### CLExecute - Execute OpenCL Kernel

Source: https://www.mql5.com/en/docs/opencl/clexecute

The CLExecute function runs an OpenCL program. It has three versions to accommodate different execution scenarios, from launching a single kernel to launching multiple kernel copies with detailed task space descriptions.

```APIDOC
## CLExecute

### Description
Launches an OpenCL kernel or multiple copies of a kernel with specified task space dimensions and offsets. This function is crucial for parallel execution of tasks on OpenCL devices.

### Method
N/A (This is a function call within MQL5, not an HTTP request)

### Endpoint
N/A

### Parameters

#### Version 1: Single Kernel Launch

- **kernel** (int) - Required - Handle to the kernel of an OpenCL program.

#### Version 2: Multiple Kernel Copies (with task space)

- **kernel** (int) - Required - Handle to the kernel of an OpenCL program.
- **work_dim** (uint) - Required - Dimension of the tasks space (e.g., 1, 2, or 3).
- **global_work_offset[]** (const uint& array) - Required - Initial offset in the tasks space.
- **global_work_size[]** (const uint& array) - Required - Total number of tasks.

#### Version 3: Multiple Kernel Copies (with local task subset specification)

- **kernel** (int) - Required - Handle to the kernel of an OpenCL program.
- **work_dim** (uint) - Required - Dimension of the tasks space.
- **global_work_offset[]** (const uint& array) - Required - Initial offset in the tasks space.
- **global_work_size[]** (const uint& array) - Required - Total number of tasks.
- **local_work_size[]** (const uint& array) - Required - Number of tasks in the local group.

### Request Example

// Version 1 Example
```mql5
bool success = CLExecute(kernel_handle);
```

// Version 2 Example
```mql5
uint work_dim = 1;
uint global_offset[] = {0};
uint global_size[] = {1000};
bool success = CLExecute(kernel_handle, work_dim, global_offset, global_size);
```

// Version 3 Example
```mql5
uint work_dim = 2;
uint global_offset[] = {0, 0};
uint global_size[] = {1024, 768};
uint local_size[] = {32, 32};
bool success = CLExecute(kernel_handle, work_dim, global_offset, global_size, local_size);
```

### Response

#### Success Response (true)
- Returns `true` if the OpenCL program execution was successful.

#### Error Response (false)
- Returns `false` if the execution failed. Use `GetLastError()` for error details.

#### Response Example

// Success
```json
{
  "result": true
}
```

// Failure
```json
{
  "result": false,
  "error_code": "<error_code>",
  "error_description": "<error_description>"
}
```

### Notes
- `work_dim` determines the dimensionality of the task space.
- `global_work_size` defines the total number of tasks (work-items) to be executed.
- `local_work_size` specifies how tasks are grouped for parallel execution within compute units. It must evenly divide `global_work_size` for each dimension.
```

--------------------------------

### Declare MqlRates Data Resource in MQL5

Source: https://www.mql5.com/en/docs/runtime/resources

Declares a resource variable to hold trading rates data from a binary file. The data is structured as MqlRates arrays.

```MQL5
#resource "data.bin" as MqlRates ExtData[]
```

--------------------------------

### Calculate and Set Order Parameters for Different Order Types (MQL5)

Source: https://www.mql5.com/en/docs/constants/structures/mqltraderequest

This snippet calculates the opening price, take profit (tp), and stop loss (sl) for different order types including BUY_LIMIT, SELL_LIMIT, BUY_STOP, and SELL_STOP. It normalizes the calculated prices using NormalizeDouble and retrieves symbol information like Ask, Bid, and point. It assumes variables like offset, point, digits, and type are pre-defined.

```MQL5
price = SymbolInfoDouble(Symbol(),SYMBOL_ASK)-offset*point;
request.tp = NormalizeDouble(price+offset*point,digits);
request.sl = NormalizeDouble(price-offset*point,digits);
request.price =NormalizeDouble(price,digits); // normalized opening price
}
else if(type==ORDER_TYPE_SELL_LIMIT)
{
price = SymbolInfoDouble(Symbol(),SYMBOL_BID)+offset*point;
request.tp = NormalizeDouble(price-offset*point,digits);
request.sl = NormalizeDouble(price+offset*point,digits);
request.price =NormalizeDouble(price,digits); // normalized opening price
}
else if(type==ORDER_TYPE_BUY_STOP)
{
price = SymbolInfoDouble(Symbol(),SYMBOL_ASK)+offset*point;
request.tp = NormalizeDouble(price+offset*point,digits);
request.sl = NormalizeDouble(price-offset*point,digits);
request.price =NormalizeDouble(price,digits); // normalized opening price
}
else if(type==ORDER_TYPE_SELL_STOP)
{
price = SymbolInfoDouble(Symbol(),SYMBOL_BID)-offset*point;
request.tp = NormalizeDouble(price-offset*point,digits);
request.sl = NormalizeDouble(price+offset*point,digits);
request.price =NormalizeDouble(price,digits); // normalized opening price
}
```

--------------------------------

### MQL5: CLExecute with Task Space Description

Source: https://www.mql5.com/en/docs/opencl/clexecute

This MQL5 function launches multiple copies of an OpenCL kernel with a defined task space. It accepts the kernel handle, the dimensionality of the task space, an offset for the tasks, and the total number of tasks.

```mql5
bool CLExecute(
int kernel, // Handle to the kernel of an OpenCL program
uint work_dim, // Dimension of the tasks space
const uint& global_work_offset[], // Initial offset in the tasks space
const uint& global_work_size[] // Total number of tasks
);
```

--------------------------------

### Declare Bitmap Resource with Path in MQL5

Source: https://www.mql5.com/en/docs/runtime/resources

Declares a bitmap resource with a specified path. This allows direct addressing of the resource via its path.

```MQL5
#resource "\\Images\\euro.bmp" as bitmap euro[][]
```

--------------------------------

### Retrieve Open Positions with MQL5 Python

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5positionsget_py

This snippet demonstrates how to connect to the MetaTrader 5 terminal, retrieve open positions for a specific symbol ('USDCHF'), and then fetch positions for symbols matching a group pattern ('*USD*'). It also shows how to display the fetched position data using a pandas DataFrame. The connection is established using mt5.initialize() and closed with mt5.shutdown().

```python
import MetaTrader5 as mt5
import pandas as pd

pd.set_option('display.max_columns', 500) 
pd.set_option('display.width', 1500) 

print("MetaTrader5 package author: ",mt5.__author__)
print("MetaTrader5 package version: ",mt5.__version__)
print()

if not mt5.initialize():
    print("initialize() failed, error code =",mt5.last_error())
    quit()
  
positions=mt5.positions_get(symbol="USDCHF")
if positions==None:
    print("No positions on USDCHF, error code={}".format(mt5.last_error()))
elif len(positions)>0:
    print("Total positions on USDCHF =",len(positions))
    for position in positions:
        print(position)
  
usd_positions=mt5.positions_get(group="*USD*")
if usd_positions==None:
    print("No positions with group=\"*USD*\", error code={}".format(mt5.last_error()))
elif len(usd_positions)>0:
    print("positions_get(group=\"*USD*\")={}".format(len(usd_positions)))
    df=pd.DataFrame(list(usd_positions),columns=usd_positions[0]._asdict().keys())
    df['time'] = pd.to_datetime(df['time'], unit='s')
    df.drop(['time_update', 'time_msc', 'time_update_msc', 'external_id'], axis=1, inplace=True)
    print(df)
  
mt5.shutdown()
```

--------------------------------

### MQL5 OnTesterInit: EA Initialization for Testing

Source: https://www.mql5.com/en/docs/basis/function/events

OnTesterInit() is called when the TesterInit event occurs before optimization. It can return an integer status code (0 for success) to indicate initialization results, including errors. A void version exists for backward compatibility but is not recommended.

```MQL5
int OnTesterInit(void)
{
  // Initialization logic before optimization
  // Return INIT_SUCCEEDED (0) on success
  return 0; // Placeholder for success
}

// For compatibility, not recommended:
// void OnTesterInit(void)
// {
//   // Initialization logic
// }
```

--------------------------------

### Place Pending Orders in MQL5

Source: https://www.mql5.com/en/docs/constants/structures/mqltraderequest

This MQL5 code snippet demonstrates how to place various types of pending orders (BUY_LIMIT, SELL_LIMIT, BUY_STOP, SELL_STOP). It initializes a trade request, sets order parameters like symbol, volume, deviation, and magic number, calculates the order price based on the order type and offset, and sends the request. Error handling for OrderSend is included.

```MQL5
//+------------------------------------------------------------------+
//| Placing pending orders |
//+------------------------------------------------------------------+
void OnStart()
{
//--- declare and initialize the trade request and result of trade request
MqlTradeRequest request={};
MqlTradeResult result={};
//--- parameters to place a pending order
request.action =TRADE_ACTION_PENDING; // type of trade operation
request.symbol =Symbol(); // symbol
request.volume =0.1; // volume of 0.1 lot
request.deviation=2; // allowed deviation from the price
request.magic =EXPERT_MAGIC; // MagicNumber of the order
int offset = 50; // offset from the current price to place the order, in points
double price;  // order triggering price
double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);  // value of point
int digits=SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);  // number of decimal places (precision)
//--- checking the type of operation
if(orderType==ORDER_TYPE_BUY_LIMIT)
{
request.type =ORDER_TYPE_BUY_LIMIT; // order type
price=SymbolInfoDouble(Symbol(),SYMBOL_ASK)-offset*point; // price for opening
request.price =NormalizeDouble(price,digits); // normalized opening price
}
else if(orderType==ORDER_TYPE_SELL_LIMIT)
{
request.type =ORDER_TYPE_SELL_LIMIT; // order type
price=SymbolInfoDouble(Symbol(),SYMBOL_BID)+offset*point; // price for opening
request.price =NormalizeDouble(price,digits); // normalized opening price
}
else if(orderType==ORDER_TYPE_BUY_STOP)
{
request.type =ORDER_TYPE_BUY_STOP; // order type
price =SymbolInfoDouble(Symbol(),SYMBOL_ASK)+offset*point; // price for opening
request.price=NormalizeDouble(price,digits); // normalized opening price
}
else if(orderType==ORDER_TYPE_SELL_STOP)
{
request.type =ORDER_TYPE_SELL_STOP; // order type
price=SymbolInfoDouble(Symbol(),SYMBOL_BID)-offset*point; // price for opening
request.price =NormalizeDouble(price,digits); // normalized opening price
}
else Alert("This example is only for placing pending orders"); // if not pending order is selected
//--- send the request
if(!OrderSend(request,result))
PrintFormat("OrderSend error %d",GetLastError()); // if unable to send the request, output the error code
//--- information about the operation
PrintFormat("retcode=%u deal=%I64u order=%I64u",result.retcode,result.deal,result.order);
}
//+------------------------------------------------------------------+
```

--------------------------------

### MQL5: Copying Time Data with ArraySetAsSeries

Source: https://www.mql5.com/en/docs/series

Demonstrates how to copy time data for the last 10 bars into two different arrays. One array is configured as a time series (recent to old), and the other as a standard array (old to recent) using ArraySetAsSeries. This highlights the difference in indexing behavior between the two array types.

```MQL5
datetime TimeAsSeries[];
//--- set access to the array like to a timeseries
ArraySetAsSeries(TimeAsSeries,true);
ResetLastError();
int copied=CopyTime(NULL,0,0,10,TimeAsSeries);
if(copied<=0)
{
Print("The copy operation of the open time values for last 10 bars has failed");
return;
}
Print("TimeCurrent =",TimeCurrent());
Print("ArraySize(Time) =",ArraySize(TimeAsSeries));
int size=ArraySize(TimeAsSeries);
for(int i=0;i<size;i++)
{
Print("TimeAsSeries["+i+"] =",TimeAsSeries[i]);
}

datetime ArrayNotSeries[];
ArraySetAsSeries(ArrayNotSeries,false);
ResetLastError();
copied=CopyTime(NULL,0,0,10,ArrayNotSeries);
if(copied<=0)
{
Print("The copy operation of the open time values for last 10 bars has failed");
return;
}
size=ArraySize(ArrayNotSeries);
for(int i=size-1;i>=0;i--)
{
Print("ArrayNotSeries["+i+"] =",ArrayNotSeries[i]);
}
```

--------------------------------

### login(login, password, server, timeout)

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5login_py

Establishes a connection to a specified trading account using the provided credentials and server information. It can optionally use saved credentials from the terminal's database.

```APIDOC
## POST /mt5/login

### Description
Connect to a trading account using specified parameters. This function attempts to establish a connection to a MetaTrader 5 trading account.

### Method
POST

### Endpoint
/mt5/login

### Parameters
#### Path Parameters
None

#### Query Parameters
None

#### Request Body
- **login** (integer) - Required - The trading account number.
- **password** (string) - Optional - The trading account password. If not provided, the saved password in the terminal database is used.
- **server** (string) - Optional - The name of the trade server as specified in the terminal. If not provided, the last used server is applied automatically.
- **timeout** (integer) - Optional - The connection timeout in milliseconds. Defaults to 60000 (60 seconds). If the connection is not established within this time, it will be forcibly terminated.

### Request Example
```json
{
  "login": 17221085,
  "password": "your_password",
  "server": "your_server.com",
  "timeout": 30000
}
```

### Response
#### Success Response (200)
- **success** (boolean) - True if the connection was successful, False otherwise.
- **account_info** (object) - If successful, details about the connected account.
- **error_code** (integer) - If unsuccessful, the error code indicating the reason for failure.

#### Response Example
```json
{
  "success": true,
  "account_info": {
    "login": 17221085,
    "trade_mode": 0,
    "leverage": 100,
    "balance": 100000.00,
    "equity": 100000.00,
    "margin": 0.00,
    "currency": "USD"
  }
}
```

```json
{
  "success": false,
  "error_code": 4001,
  "message": "Authorization failed"
}
```
```

--------------------------------

### MQL5 Interface and Class Implementation for Polymorphism

Source: https://www.mql5.com/en/docs/basis/types/classes

This MQL5 code defines an interface 'IAnimal' and two classes 'CCat' and 'CDog' that implement this interface. It demonstrates how to use an array of interface pointers to achieve polymorphism, allowing calls to the 'Sound' method on different animal objects.

```MQL5
//--- Basic interface for describing animals
interface IAnimal
{
//--- The methods of the interface have public access by default
void Sound(); // The sound produced by the animal
};
//+------------------------------------------------------------------+
//| The CCat class is inherited from the IAnimal interface |
//+------------------------------------------------------------------+
class CCat : public IAnimal
{
public:
CCat() { Print("Cat was born"); }
~CCat() { Print("Cat is dead"); }
//--- Implementing the Sound method of the IAnimal interface
void Sound(){ Print("meou"); }
};
//+------------------------------------------------------------------+
//| The CDog class is inherited from the IAnimal interface |
//+------------------------------------------------------------------+
class CDog : public IAnimal
{
public:
CDog() { Print("Dog was born"); }
~CDog() { Print("Dog is dead"); }
//--- Implementing the Sound method of the IAnimal interface
void Sound(){ Print("guaf"); }
};
//+------------------------------------------------------------------+
//| Script program start function |
//+------------------------------------------------------------------+
void OnStart()
{
//--- An array of pointers to objects of the IAnimal type
IAnimal *animals[2];
//--- Creating child classes of IAnimal and saving pointers to them into an array
animals[0]=new CCat;
animals[1]=new CDog;
//--- Calling the Sound() method of the basic IAnimal interface for each child
for(int i=0;i<ArraySize(animals);++i)
animals[i].Sound();
//--- Deleting objects
for(int i=0;i<ArraySize(animals);++i)
delete animals[i];
}
```

--------------------------------

### MQL5 Structure Declaration with Data Types and Alignment

Source: https://www.mql5.com/en/docs/basis/types/classes

Illustrates the declaration of a structure named 'trade_settings' in MQL5, including various data types like uchar, char, short, int, and double. It demonstrates how to use 'fillers' (reserved members) for manual byte alignment, which is primarily useful when interfacing with DLL functions.

```MQL5
struct trade_settings {
  uchar slippage; // value of the permissible slippage-size 1 byte
  char reserved1; // skip 1 byte
  short reserved2; // skip 2 bytes
  int reserved4; // another 4 bytes are skipped. ensure alignment of the boundary 8 bytes
  double take; // values of the price of profit fixing
  double stop; // price value of the protective stop
};
```

--------------------------------

### MQL5 OpenCL Resource Cleanup Functions

Source: https://www.mql5.com/en/docs/opencl/clprogramcreate

This snippet lists functions used for cleaning up OpenCL resources.

```MQL5
CLProgramFree
CLBufferFree
CLKernelFree
CLContextFree
```

--------------------------------

### PlaySound() with Specific File Path in MQL5

Source: https://www.mql5.com/en/docs/runtime/resources

Illustrates how to play a sound file located in a subfolder of the terminal data directory. It shows the correct syntax for PlaySound() when referencing files within the MQL5\Files folder, using double backslashes as separators. This function requires the sound file to be present at the specified path.

```MQL5
//--- play Demo.wav from the folder terminal_directory_data\MQL5\Files\
PlaySound("\\Files\\Demo.wav");
```

--------------------------------

### MQL5 Gamma Distribution: Generate and Plot Sample Data

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/gamma

This MQL5 script demonstrates how to generate a sample of random numbers from a gamma distribution using MathRandomGamma and then plots a histogram of the sample alongside the theoretical probability density curve. It utilizes the CGraphic class for visualization and includes helper functions for histogram calculation and sequence generation.

```MQL5
#include <Graphics\Graphic.mqh>
#include <Math\Stat\Gamma.mqh>
#include <Math\Stat\Math.mqh>

property script_show_inputs

input double alpha=9; // the first parameter of distribution (shape)
input double beta=0.5; // the second parameter of distribution (scale)

void OnStart()
{
  ChartSetInteger(0,CHART_SHOW,false);
  MathSrand(GetTickCount());

  long chart=0;
  string name="GraphicNormal";
  int n=1000000; // the number of values in the sample
  int ncells=51; // the number of intervals in the histogram
  double x[]; // centers of the histogram intervals
  double y[]; // the number of values from the sample falling within the interval
  double data[]; // sample of random values
  double max,min; // the maximum and minimum values in the sample

  MathRandomGamma(alpha,beta,n,data);
  CalculateHistogramArray(data,x,y,max,min,ncells);

  double step;
  GetMaxMinStepValues(max,min,step);
  step=MathMin(step,(max-min)/ncells);

  double x2[];
  double y2[];
  MathSequence(min,max,step,x2);
  MathProbabilityDensityGamma(x2,alpha,beta,false,y2);

  double theor_max=y2[ArrayMaximum(y2)];
  double sample_max=y[ArrayMaximum(y)];
  double k=sample_max/theor_max;
  for(int i=0; i<ncells; i++)
    y[i]/=k;

  CGraphic graphic;
  if(ObjectFind(chart,name)<0)
    graphic.Create(chart,name,0,0,0,780,380);
  else
    graphic.Attach(chart,name);

  graphic.BackgroundMain(StringFormat("Gamma distribution alpha=%G beta=%G",alpha,beta));
  graphic.BackgroundMainSize(16);
  graphic.YAxis().AutoScale(false);
  graphic.YAxis().Max(NormalizeDouble(theor_max,1));
  graphic.YAxis().Min(0);

  graphic.CurveAdd(x,y,CURVE_HISTOGRAM,"Sample").HistogramWidth(6);
  graphic.CurveAdd(x2,y2,CURVE_LINES,"Theory");
  graphic.CurvePlotAll();
  graphic.Update();
}

//+------------------------------------------------------------------+
//| Calculate frequencies for data set |
//+------------------------------------------------------------------+
bool CalculateHistogramArray(const double &data[],double &intervals[],double &frequency[],
                             double &maxv,double &minv,const int cells=10)
{
  if(cells<=1) return (false);
  int size=ArraySize(data);
  if(size<cells*10) return (false);

  minv=data[ArrayMinimum(data)];
  maxv=data[ArrayMaximum(data)];
  double range=maxv-minv;
  double width=range/cells;
  if(width==0) return false;

  ArrayResize(intervals,cells);
  ArrayResize(frequency,cells);

  //--- define the interval centers
  for(int i=0; i<cells; i++)
  {
    intervals[i]=minv+(i+0.5)*width;
    frequency[i]=0;
  }

  //--- fill the frequencies of falling within the interval
  for(int i=0; i<size; i++)
  {
    int ind=int((data[i]-minv)/width);
    if(ind>=cells) ind=cells-1;
    frequency[ind]++;
  }
  return (true);
}
//+------------------------------------------------------------------+
//| Calculates values for sequence generation |

```

--------------------------------

### Generate Chi-squared Distribution Sample and Plot Histogram - MQL5

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/chisquare

This MQL5 script demonstrates how to generate a sample of random numbers from a chi-squared distribution using MathRandomChiSquare. It then calculates histogram data, plots the sample's histogram, and overlays the theoretical probability density function using CGraphic. Dependencies include Math.mqh, ChiSquare.mqh, and Graphic.mqh.

```MQL5
#include <Graphics\Graphic.mqh>
#include <Math\Stat\ChiSquare.mqh>
#include <Math\Stat\Math.mqh>

input double nu_par=5; // the number of degrees of freedom

void OnStart()
{
   ChartSetInteger(0,CHART_SHOW,false);
   MathSrand(GetTickCount());
   
   long chart=0;
   string name="GraphicNormal";
   int n=1000000; // the number of values in the sample
   int ncells=51; // the number of intervals in the histogram
   double x[]; // centers of the histogram intervals
   double y[]; // the number of values from the sample falling within the interval
   double data[]; // sample of random values
   double max,min; // the maximum and minimum values in the sample
   
   MathRandomChiSquare(nu_par,n,data);
   
   CalculateHistogramArray(data,x,y,max,min,ncells);
   
   double step;
   GetMaxMinStepValues(max,min,step);
   step=MathMin(step,(max-min)/ncells);
   
   double x2[];
   double y2[];
   MathSequence(min,max,step,x2);
   MathProbabilityDensityChiSquare(x2,nu_par,false,y2);
   
   double theor_max=y2[ArrayMaximum(y2)];
   double sample_max=y[ArrayMaximum(y)];
   double k=sample_max/theor_max;
   for(int i=0; i<ncells; i++)
      y[i]/=k;
      
   CGraphic graphic;
   if(ObjectFind(chart,name)<0)
      graphic.Create(chart,name,0,0,0,780,380);
   else
      graphic.Attach(chart,name);
      
   graphic.BackgroundMain(StringFormat("ChiSquare distribution nu=%G ",nu_par));
   graphic.BackgroundMainSize(16);
   
   graphic.CurveAdd(x,y,CURVE_HISTOGRAM,"Sample").HistogramWidth(6);
   graphic.CurveAdd(x2,y2,CURVE_LINES,"Theory");
   graphic.CurvePlotAll();
   
   graphic.Update();
}

bool CalculateHistogramArray(const double &data[],double &intervals[],double &frequency[],
   double &maxv,double &minv,const int cells=10)
{
   if(cells<=1) return (false);
   int size=ArraySize(data);
   if(size<cells*10) return (false);
   minv=data[ArrayMinimum(data)];
   maxv=data[ArrayMaximum(data)];
   double range=maxv-minv;
   double width=range/cells;
   if(width==0) return false;
   ArrayResize(intervals,cells);
   ArrayResize(frequency,cells);
   
   for(int i=0; i<cells; i++)
   {
      intervals[i]=minv+(i+0.5)*width;
      frequency[i]=0;
   }
   
   for(int i=0; i<size; i++)
   {
      int ind=int((data[i]-minv)/width);
      if(ind>=cells) ind=cells-1;
      frequency[ind]++;
   }
   return (true);
}

void GetMaxMinStepValues(double &maxv,double &minv,double &stepv)
{
   //--- calculate the absolute range of the sequence to obtain the precision of normalization
}

```

--------------------------------

### MQL5: Printing Object Member Values

Source: https://www.mql5.com/en/docs/basis/types/classes

This snippet demonstrates how to print the string representation of member variables from various object instances in MQL5. It shows a common pattern for debugging or inspecting object states.

```MQL5
Print("foo1.m_call_time=",foo1.ToString());
Print("foo2.m_call_time=",foo2.ToString());
Print("foo3.m_call_time=",foo3.ToString());
Print("foo4.m_call_time=",foo4.ToString());
Print("foo5.m_call_time=",foo5.ToString());
Print("pfoo6.m_call_time=",pfoo6.ToString());
Print("pfoo7.m_call_time=",pfoo7.ToString());
Print("pfoo8.m_call_time=",pfoo8.ToString());
Print("pfoo9.m_call_time=",pfoo9.ToString());
```

--------------------------------

### MQL5 Structure Member Size Calculation

Source: https://www.mql5.com/en/docs/basis/types/classes

Demonstrates how to calculate and print the size of individual members within an MQL5 structure. It also shows the total size of the structure, illustrating how member sizes contribute to the overall structure size. This helps in understanding memory layout.

```MQL5
Print("sizeof(ch_sh_in.s)=",sizeof(ch_sh_in.s));
Print("sizeof(ch_sh_in.i)=",sizeof(ch_sh_in.i));

//--- make sure the size of POD structure is equal to the sum of its members' size
Print("sizeof(CharShortInt)=",sizeof(CharShortInt));
```

--------------------------------

### MQL5 CustomMqlTick Structure and Member-wise Copying

Source: https://www.mql5.com/en/docs/basis/types/classes

Demonstrates the creation of a custom structure `CustomMqlTick` similar to the built-in `MqlTick`. It illustrates that direct copying or typecasting between unrelated simple structures is forbidden, necessitating a member-by-member copy. It also shows that objects of the same custom structure type can be copied directly, and arrays of these structures can be populated and printed.

```MQL5
//+------------------------------------------------------------------+
//| Script program start function |
//+------------------------------------------------------------------+
void OnStart()
{
//--- develop the structure similar to the built-in MqlTick
struct CustomMqlTick
{
datetime time; // Last price update time
double bid; // Current Bid price
double ask; // Current Ask price
double last; // Current price of the last trade (Last)
ulong volume; // Volume for the current Last price
long time_msc; // Last price update time in milliseconds
uint flags; // Tick flags 
};
//--- get the last tick value
MqlTick last_tick;
CustomMqlTick my_tick1,my_tick2;
//--- attempt to copy data from MqlTick to CustomMqlTick
if(SymbolInfoTick(Symbol(),last_tick))
{
//--- copying unrelated simple structures is forbidden
//1. my_tick1=last_tick; // compiler returns an error here

//--- typecasting unrelated structures to each other is forbidden as well
//2. my_tick1=(CustomMqlTick)last_tick;// compiler returns an error here

//--- therefore, copy the structure members one by one 
my_tick1.time=last_tick.time;
my_tick1.bid=last_tick.bid;
my_tick1.ask=last_tick.ask;
my_tick1.volume=last_tick.volume;
my_tick1.time_msc=last_tick.time_msc;
my_tick1.flags=last_tick.flags;

//--- it is allowed to copy the objects of the same type of CustomMqlTick the following way
my_tick2=my_tick1;

//--- create an array out of the objects of the simple CustomMqlTick structure and write values to it
CustomMqlTick arr[2];
arr[0]=my_tick1;
arr[1]=my_tick2;
ArrayPrint(arr);
//--- example of displaying values of the array containing the objects of CustomMqlTick type
/*
[time] [bid] [ask] [last] [volume] [time_msc] [flags]
[0] 2017.05.29 15:04:37 1.11854 1.11863 +0.00000 1450000 1496070277157 2
[1] 2017.05.29 15:04:37 1.11854 1.11863 +0.00000 1450000 1496070277157 2
*/
}
else
Print("SymbolInfoTick() failed, error = ",GetLastError());
}

```

--------------------------------

### MQL5 OpenCL Pi Calculation and Resource Management

Source: https://www.mql5.com/en/docs/opencl/clbufferread

This MQL5 code calculates Pi using OpenCL. It initializes OpenCL objects, allocates memory, executes a kernel, reads results, and frees resources. Error handling is included for OpenCL operations. Dependencies include MQL5's OpenCL functions.

```mql5
int clMem=CLBufferCreate(clCtx, _divisor*sizeof(double), CL_MEM_READ_WRITE);   
CLSetKernelArgMem(clKrn, 0, clMem);   
  
const uint offs[1] = {0};   
const uint works[1] = {_divisor};   
//--- launch OpenCL program   
ulong start=GetMicrosecondCount();   
if(!CLExecute(clKrn, 1, offs, works))   
{
Print("CLExecute(clKrn, 1, offs, works) failed! Error ", GetLastError());   
CLFreeAll(clMem, clKrn, clPrg, clCtx);   
return(-1);
}
//--- get results from OpenCL device   
vector buffer(_divisor);   
if(!CLBufferRead(clMem, 0, buffer))   
{
Print("CLBufferRead(clMem, 0, buffer) failed! Error ", GetLastError());   
CLFreeAll(clMem, clKrn, clPrg, clCtx);   
return(-1);
}
//--- sum all values to calculate Pi   
double Pi=buffer.Sum()*_step;   
  
double time=(GetMicrosecondCount()-start)/1000.;   
Print("OpenCL: Pi calculated for "+D2S(time, 2)+" ms");   
Print("Pi = "+DoubleToString(Pi, 12));   
//--- free memory   
CLFreeAll(clMem, clKrn, clPrg, clCtx);   
//--- success   
return(0);
}
```

--------------------------------

### Python Integration - Version

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5version_py

Retrieves the MetaTrader 5 terminal version, build, and release date.

```APIDOC
## Get Terminal Version

### Description
Returns the MetaTrader 5 terminal version, build, and release date.

### Method
Python Function Call

### Endpoint
N/A

### Parameters
None

### Request Example
```python
import MetaTrader5 as mt5

if mt5.initialize():
    print(mt5.version())
    mt5.shutdown()
```

### Response
#### Success Response
- **version** (integer) - The MetaTrader 5 terminal version.
- **build** (integer) - The build number.
- **release_date** (string) - The build release date.

#### Response Example
```
[500, 2007, '25 Feb 2019']
```

### Errors
- Returns `None` in case of an error. Error information can be obtained using `last_error()`.
```

--------------------------------

### Retrieve Symbol Information in Python

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5symbolselect_py

This code demonstrates how to fetch detailed information about a financial symbol using the `SymbolInfo` function from the MetaTrader5 package. The output includes various trading parameters, pricing data, and symbol properties. The `symbol_info()._asdict()` method converts the symbol information into a dictionary for easier access.

```python
import MetaTrader5 as mt5

# Initialize connection to the MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed, error code {}".format(mt5.last_error()))
    mt5.shutdown()

# get symbol information
symbol_info = mt5.symbol_info("EURCAD")
print(symbol_info)

# get symbol_info()._asdict() as dictionary
symbol_info_dict = symbol_info._asdict()
print(symbol_info_dict)
```

--------------------------------

### MQL5: Open Buy Position

Source: https://www.mql5.com/en/docs/constants/structures/mqltraderequest

This MQL5 code snippet demonstrates how to open a Buy position for a given symbol. It sets the trade action to TRADE_ACTION_DEAL, specifies the symbol, volume, order type, price, deviation, and a magic number. Error handling for the OrderSend function is included.

```MQL5
#define EXPERT_MAGIC 123456 // MagicNumber of the expert  
//+------------------------------------------------------------------+  
//| Opening Buy position |  
//+------------------------------------------------------------------+  
void OnStart()  
{  
//--- declare and initialize the trade request and result of trade request  
MqlTradeRequest request={};  
MqlTradeResult result={};  
//--- parameters of request  
request.action =TRADE_ACTION_DEAL; // type of trade operation  
request.symbol =Symbol(); // symbol  
request.volume =0.1; // volume of 0.1 lot  
request.type =ORDER_TYPE_BUY; // order type  
request.price =SymbolInfoDouble(Symbol(),SYMBOL_ASK); // price for opening  
request.deviation=5; // allowed deviation from the price  
request.magic =EXPERT_MAGIC; // MagicNumber of the order  
//--- send the request  
if(!OrderSend(request,result))  
PrintFormat("OrderSend error %d",GetLastError()); // if unable to send the request, output the error code  
//--- information about the operation  
PrintFormat("retcode=%u deal=%I64u order=%I64u",result.retcode,result.deal,result.order);  
}
```

--------------------------------

### MQL5 OpenCL Data Processing and Verification

Source: https://www.mql5.com/en/docs/opencl/clprogramcreate

This MQL5 code processes arrays using OpenCL for computation and then verifies the results. It involves filling initial data, executing an OpenCL kernel, reading back computed data, and calculating the total error between the original and computed arrays. It also demonstrates the cleanup of OpenCL objects.

```MQL5
for(int i=0; i<ARRAY_SIZE; i++)   
{
//--- fill arrays with function MathCos(i+j)   
DataArray1[i+local_offset]=MathCos(i+j);
DataArray2[i+local_offset]=MathCos(i+j);
}
};
//--- test CPU calculation   
for(int j=0; j<TOTAL_ARRAYS; j++)   
{
//--- calculation of the array with index j   
Test_CPU(DataArray1,ARRAY_SIZE,j,TOTAL_ARRAYS);
}
//--- prepare CLExecute params   
uint offset[]={0};
//--- global work size   
uint work[]={TOTAL_ARRAYS};
//--- write data to OpenCL buffer   
CLBufferWrite(cl_mem,DataArray2);
//--- execute OpenCL kernel   
CLExecute(cl_krn,1,offset,work);
//--- read data from OpenCL buffer   
CLBufferRead(cl_mem,DataArray2);
//--- total error   
double total_error=0;
//--- compare results and calculate error   
for(int j=0; j<TOTAL_ARRAYS; j++)   
{
//--- calculate local offset for jth array   
uint local_offset=j*ARRAY_SIZE;
//--- compare the results   
for(int i=0; i<ARRAY_SIZE; i++)
{
double v1=DataArray1[i+local_offset];
double v2=DataArray2[i+local_offset];
double delta=MathAbs(v2-v1);
total_error+=delta;
//--- show first and last arrays   
if((j==0) || (j==TOTAL_ARRAYS-1))   
PrintFormat("array %d of %d, element [%d]: %f, %f, [error]=%f",j+1,TOTAL_ARRAYS,i,v1,v2,delta);
}
}
PrintFormat("Total error: %f",total_error);
//--- delete OpenCL objects   
//--- free OpenCL buffer   
CLBufferFree(cl_mem);
//--- free OpenCL kernel   
CLKernelFree(cl_krn);
//--- free OpenCL program   
CLProgramFree(cl_prg);
//--- free OpenCL context   
CLContextFree(cl_ctx);
//---
return(0);
}
```

--------------------------------

### MQL5 ARGB Color Representation and Manipulation

Source: https://www.mql5.com/en/docs/basis/types/classes

This MQL5 code snippet demonstrates how to work with ARGB color values. It shows how to convert between color types, extract ARGB components, and manipulate the alpha channel. It utilizes functions like ArrayCopy, PrintFormat, Alpha(), and ColorToARGB.

```MQL5
ARGB argb_color(test_color);
//--- copy the bytes array
ArrayCopy(argb,argb_color.argb);
//--- here is how it looks in ARGB representation
PrintFormat("0x%.8X - ARGB representation with the alpha channel=0x%.2x, ARGB=(%d,%d,%d,%d)",
argb_color.clr,argb_color.Alpha(),argb[3],argb[2],argb[1],argb[0]);
//--- add opacity level
argb_color.Alpha(alpha);
//--- try defining ARGB as 'color' type
Print("ARGB as color=( ",argb_color.clr,") alpha channel=",argb_color.Alpha());
//--- copy the bytes array
ArrayCopy(argb,argb_color.argb);
//--- here is how it looks in ARGB representation
PrintFormat("0x%.8X - ARGB representation with the alpha channel=0x%.2x, ARGB=(%d,%d,%d,%d)",
argb_color.clr,argb_color.Alpha(),argb[3],argb[2],argb[1],argb[0]);
//--- check with the ColorToARGB() function results
PrintFormat("0x%.8X - result of ColorToARGB(%s,0x%.2x)",ColorToARGB(test_color,alpha),
ColorToString(test_color,true),alpha);
}
```

--------------------------------

### Enable Double Precision in OpenCL (MQL5)

Source: https://www.mql5.com/en/docs/opencl

Adds a directive to an OpenCL program to enable support for double-precision floating-point numbers. This is necessary for some computations but may not be supported by all graphics cards, potentially leading to compilation errors.

```MQL5
#pragma OPENCL EXTENSION cl_khr_fp64 : enable
```

--------------------------------

### Check Trade Operation Sufficiency with MQL5 Python Integration

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5ordercheck_py

This Python snippet demonstrates how to use the MetaTrader5 library to check the sufficiency of funds for a trading operation. It initializes the connection, prepares a trade request, and utilizes the `order_check` function. It includes error handling for initialization and symbol selection.

```python
import MetaTrader5 as mt5

# display data on the MetaTrader 5 package
print("MetaTrader5 package author: ", mt5.__author__)
print("MetaTrader5 package version: ", mt5.__version__)

# establish connection to MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed, error code =", mt5.last_error())
    quit()

# get account currency
account_currency = mt5.account_info().currency
print("Account currency:", account_currency)

# prepare the request structure
symbol = "USDJPY"
symbol_info = mt5.symbol_info(symbol)
if symbol_info is None:
    print(symbol, "not found, can not call order_check()")
    mt5.shutdown()
    quit()

# if the symbol is unavailable in MarketWatch, add it
if not symbol_info.visible:
    print(symbol, "is not visible, trying to switch on")
    if not mt5.symbol_select(symbol, True):
        print("symbol_select({}}) failed, exit", symbol)
        mt5.shutdown()
        quit()

```

--------------------------------

### MQL5: Opening a Buy Position with OrderSend

Source: https://www.mql5.com/en/docs/constants/tradingconstants/enum_trade_request_actions

Demonstrates how to open a Buy position using the OrderSend() function in MQL5. It sets the trade action to TRADE_ACTION_DEAL, specifies the symbol, volume, order type, price, deviation, and magic number. Handles potential errors during order sending.

```MQL5
#define EXPERT_MAGIC 123456 // MagicNumber of the expert
//+------------------------------------------------------------------+
//| Opening Buy position |
//+------------------------------------------------------------------+
void OnStart()
{
//--- declare and initialize the trade request and result of trade request
MqlTradeRequest request={};
MqlTradeResult result={};
//--- parameters of request
request.action =TRADE_ACTION_DEAL; // type of trade operation
request.symbol =Symbol(); // symbol
request.volume =0.1; // volume of 0.1 lot
request.type =ORDER_TYPE_BUY; // order type
request.price =SymbolInfoDouble(Symbol(),SYMBOL_ASK); // price for opening
request.deviation=5; // allowed deviation from the price
request.magic =EXPERT_MAGIC; // MagicNumber of the order
//--- send the request
if(!OrderSend(request,result))
PrintFormat("OrderSend error %d",GetLastError()); // if unable to send the request, output the error code
//--- information about the operation
PrintFormat("retcode=%u deal=%I64u order=%I64u",result.retcode,result.deal,result.order);
}
//+------------------------------------------------------------------+
```

--------------------------------

### MQL5: Open and Close Market Depth Subscription

Source: https://www.mql5.com/en/docs/marketinformation/marketbookadd

This MQL5 snippet demonstrates how to open a Depth of Market subscription for a given symbol using MarketBookAdd and subsequently close it with MarketBookRelease. It includes error handling for the subscription process and provides feedback via the journal.

```MQL5
#define SYMBOL_NAME "GBPUSD"   
  
//+------------------------------------------------------------------+
//| Script program start function |
//+------------------------------------------------------------------+
void OnStart()
{
//--- open the market depth for SYMBOL_NAME symbol
if(!MarketBookAdd(SYMBOL_NAME))
{
PrintFormat("MarketBookAdd(%s) failed. Error ", SYMBOL_NAME, GetLastError());
return;
}

//--- send the message about successfully opening the market depth to the journal
PrintFormat("The MarketBook for the '%s' symbol was successfully opened and a subscription to change it was received", SYMBOL_NAME);

//--- wait 2 seconds
Sleep(2000);

//--- upon completion, unsubscribe from the open market depth
ResetLastError();
if(MarketBookRelease(SYMBOL_NAME))
PrintFormat("MarketBook for the '%s' symbol was successfully closed", SYMBOL_NAME);
else
PrintFormat("Error %d occurred when closing MarketBook using the '%s' symbol", GetLastError(), SYMBOL_NAME);

/*
result:
The MarketBook for the 'GBPUSD' symbol was successfully opened and a subscription to change it was received
MarketBook for the 'GBPUSD' symbol was successfully closed
*/
}
```

--------------------------------

### MQL5 Union for Color Type to ARGB Conversion

Source: https://www.mql5.com/en/docs/basis/types/classes

Illustrates an MQL5 union designed for converting MQL5's `color` type (BGR format) into an ARGB representation. This union utilizes a constructor and methods to manage the byte manipulation required for the conversion, showcasing advanced union features like methods and constructors for data interpretation and transformation.

```MQL5
union ARGB
{
uchar argb[4];
color clr;

ARGB(color col,uchar a=0){Color(col,a);};
~ARGB(){};

public:
uchar Alpha(){return(argb[3]);};
void Alpha(const uchar alpha){argb[3]=alpha;};
color Color(){ return(color(clr));};

private:
void Color(color col,uchar alpha)
{
clr=col;
argb[3]=alpha;
uchar t=argb[0];argb[0]=argb[2];argb[2]=t;
}
};

void OnStart()
{
uchar alpha=0x55;
color test_color=clrDarkOrange;
uchar argb[];
PrintFormat("0x%.8X - here is how the 'color' type look like for %s, BGR=(%s)",
test_color,ColorToString(test_color,true),ColorToString(test_color));
}
```

--------------------------------

### MQL5 Class Definition with Constructors

Source: https://www.mql5.com/en/docs/basis/types/classes

Defines a class 'MyDateClass' with a default constructor and a parametric constructor. These constructors are used to initialize the date and time members of the class, either with the current time or specific hour, minute, and second values.

```MQL5
//+------------------------------------------------------------------+
//| A class for working with a date |
//+------------------------------------------------------------------+
class MyDateClass
{
private:
int m_year; // Year
int m_month; // Month
int m_day; // Day of the month
int m_hour; // Hour in a day
int m_minute; // Minutes
int m_second; // Seconds
public:
//--- Default constructor
MyDateClass(void);
//--- Parametric constructor
MyDateClass(int h,int m,int s);
};

```

--------------------------------

### MQL5: Scientific Notation for Real Constants

Source: https://www.mql5.com/en/docs/basis/types/double

Illustrates the use of scientific notation (e.g., `1.12e-25`) for representing real constants in MQL5. This method allows for more compact representation of very large or very small numbers. It also shows how `DoubleToString` can format these numbers.

```MQL5
double c1=1.12123515e-25;
double c2=0.000000000000000000000000112123515;

Print("1. c1 =",DoubleToString(c1,16));
// Result: 1. c1 = 0.0000000000000000

Print("2. c1 =",DoubleToString(c1,-16));
// Result: 2. c1 = 1.1212351499999999e-025

Print("3. c2 =",DoubleToString(c2,-16));
// Result: 3. c2 = 1.1212351499999999e-025
```

--------------------------------

### MQL5: Comparing Real Numbers with Tolerance (Epsilon)

Source: https://www.mql5.com/en/docs/basis/types/double

Presents a function `EqualDoubles` to compare two `double` numbers for approximate equality within a specified tolerance (`epsilon`). It also demonstrates comparing a `double` and a `float` using this method, showing their potential differences.

```MQL5
bool EqualDoubles(double d1,double d2,double epsilon)
{
if(epsilon<0)
 epsilon=-epsilon;
//---
if(d1-d2>epsilon)
 return false;
if(d1-d2<-epsilon)
 return false;
//---
return true;
}
void OnStart()
{
double d_val=0.7;
float f_val=0.7;
if(EqualDoubles(d_val,f_val,0.000000000000001))
Print(d_val," equals ",f_val);
else
Print("Different: d_val = ",DoubleToString(d_val,16)," f_val = ",DoubleToString(f_val,16));
// Result: Different: d_val= 0.7000000000000000 f_val= 0.6999999880790710
```

--------------------------------

### Display MQL5 Dataframe in Python

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5copyratesrange_py

This Python snippet demonstrates how to display the first 10 rows of a dataframe containing financial data obtained from MQL5. It utilizes the print function for output and assumes the data is stored in a 'rates_frame' object.

```python
# display data  
print("\nDisplay dataframe with data")  
print(rates_frame.head(10))
```

--------------------------------

### Declare String Data Resource in MQL5

Source: https://www.mql5.com/en/docs/runtime/resources

Declares a resource variable to hold string data from a text file. Supports ANSI, UTF-8, and UTF-16 encodings, converting to Unicode upon reading.

```MQL5
#resource "data.txt" as string ExtCode
```

--------------------------------

### Create DirectX Graphics Context

Source: https://www.mql5.com/en/docs/directx/dxcontextcreate

Creates a graphics context for rendering frames of a specified size. Returns a handle to the context or INVALID_HANDLE on error. Objects created within this context are tied to it and must be released using DXRelease.

```MQL5
int DXContextCreate(
  uint width, // width in pixels
  uint height // height in pixels
);

```

--------------------------------

### Retrieve Active Orders by Symbol using Python

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5ordersget_py

This Python code snippet demonstrates how to connect to MetaTrader 5 and retrieve all active trading orders for a specific symbol, such as 'GBPUSD'. It initializes the connection, fetches orders, and prints them or an error message if no orders are found.

```python
import MetaTrader5 as mt5
import pandas as pd

pd.set_option('display.max_columns', 500)
pd.set_option('display.width', 1500)

print("MetaTrader5 package author: ", mt5.__author__)
print("MetaTrader5 package version: ", mt5.__version__)
print()

if not mt5.initialize():
    print("initialize() failed, error code =", mt5.last_error())
    quit()

ord=mt5.orders_get(symbol="GBPUSD")
if ord is None:
    print("No orders on GBPUSD, error code={}".format(mt5.last_error()))
else:
    print("Total orders on GBPUSD:",len(ord))
    for order in ord:
        print(order)
    print()

mt5.shutdown()
```

--------------------------------

### Display Chart using Matplotlib in Python

Source: https://www.mql5.com/en/docs/python_metatrader5

This snippet shows how to display a chart using Matplotlib in Python. It assumes that chart data has been prepared and is ready for display. The primary function used is `plt.show()`.

```python
# display the chart
plt.show()
```

--------------------------------

### MQL5 Derived Class Constructor Calling Parent and Member Initialization

Source: https://www.mql5.com/en/docs/basis/types/classes

Illustrates a derived class `CBar` in MQL5 that inherits from `CFoo`. Its default constructor calls the parent `CFoo` constructor and initializes a member `m_member` (an object of `CFoo`), printing the function name upon execution.

```MQL5
//+------------------------------------------------------------------+
//| Class derived from CFoo |
//+------------------------------------------------------------------+
class CBar : CFoo
{
CFoo m_member; // A class member is an object of the parent
public:
//--- A default constructor in the initialization list calls the constructor of a parent
CBar(): m_member(_Symbol), CFoo("CBAR") {Print(__FUNCTION__);}
};

```

--------------------------------

### MQL5 Deinitialization Event Handler: OnDeinit Function

Source: https://www.mql5.com/en/docs/basis/function/events

The OnDeinit() function is the Deinit event handler, called during deinitialization for Expert Advisors and indicators. It must be of void type and accept a single const int parameter representing the deinitialization reason. This function is not used in scripts.

```MQL5
void OnDeinit(const int reason);
```

--------------------------------

### Declare Binary Data Resource in MQL5

Source: https://www.mql5.com/en/docs/runtime/resources

Declares a resource variable to hold numeric array data from a binary file. The data is treated as integers.

```MQL5
#resource "data.bin" as int ExtData[]
```

--------------------------------

### Create DirectX Shader

Source: https://www.mql5.com/en/docs/directx/dxcontextcreate

Creates a shader object (vertex or pixel shader). Shaders define the rendering logic on the GPU. Requires a valid context handle and shader bytecode.

```MQL5
int DXShaderCreate(
  int context_handle, // handle of the graphic context
  uchar &bytecode[]   // shader bytecode
);

```

--------------------------------

### MQL5: Calculate and Compare Statistical Moments

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat

This MQL5 code snippet calculates the mean, variance, skewness, and kurtosis of a dataset. It then computes the theoretical values for these moments assuming a normal distribution and prints both the calculated and theoretical values, along with their differences.

```MQL5
PrintFormat("Calculated %.10f %.10f %.10f %.10f",mean,variance,skewness,kurtosis);  
//--- calculate the theoretical values of the moments and compare them with the obtained values  
if(MathMomentsNormal(mu,sigma,normal_mean,normal_variance,normal_skewness,normal_kurtosis,error_code1))  
{
PrintFormat("Theoretical %.10f %.10f %.10f %.10f",normal_mean,normal_variance,normal_skewness,normal_kurtosis);  
PrintFormat("Difference %.10f %.10f %.10f %.10f",mean-normal_mean,variance-normal_variance,skewness-normal_skewness,kurtosis-normal_kurtosis);  
}
```

--------------------------------

### Prepare and Check Trade Order with MetaTrader5 in Python

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5ordercheck_py

This snippet shows how to prepare a trade request dictionary, including symbol information, order type, volume, stop loss, and take profit levels. It then uses the `mt5.order_check()` function to validate the request and prints the result. The result is also converted to a dictionary for element-wise access, and if the result contains a 'request' field, that nested structure is also iterated.

```python
# prepare the request
point=mt5.symbol_info(symbol).point
request = {
"action": mt5.TRADE_ACTION_DEAL,
"symbol": symbol,
"volume": 1.0,
"type": mt5.ORDER_TYPE_BUY,
"price": mt5.symbol_info_tick(symbol).ask,
"sl": mt5.symbol_info_tick(symbol).ask-100*point,
"tp": mt5.symbol_info_tick(symbol).ask+100*point,
"deviation": 10,
"magic": 234000,
"comment": "python script",
"type_time": mt5.ORDER_TIME_GTC,
"type_filling": mt5.ORDER_FILLING_RETURN,
} 

# perform the check and display the result 'as is' 
result = mt5.order_check(request) 
print(result);
# request the result as a dictionary and display it element by element 
result_dict=result._asdict()
for field in result_dict.keys():
print(" {}={}".format(field,result_dict[field]))
# if this is a trading request structure, display it element by element as well 
if field=="request":
traderequest_dict=result_dict[field]._asdict()
for tradereq_filed in traderequest_dict:
print(" traderequest: {}={}".format(tradereq_filed,traderequest_dict[tradereq_filed]))

# shut down connection to the MetaTrader 5 terminal
mt5.shutdown()
```

--------------------------------

### Retrieve EURUSD Rate Data in MQL5

Source: https://www.mql5.com/en/docs/python_metatrader5

This snippet demonstrates fetching historical rate data for EURUSD using the `eurusd_rates` function in MQL5. It retrieves a specified number of bars, returning data such as time, open, high, low, close, volume, spread, and real volume.

```mql5
eurusd_rates( 1000 )
(1580149260, 1.10132, 1.10151, 1.10131, 1.10149, 44, 1, 0)
(1580149320, 1.10149, 1.10161, 1.10143, 1.10154, 42, 1, 0)
(1580149380, 1.10154, 1.10176, 1.10154, 1.10174, 40, 2, 0)
(1580149440, 1.10174, 1.10189, 1.10168, 1.10187, 47, 1, 0)
(1580149500, 1.10185, 1.10191, 1.1018, 1.10182, 53, 1, 0)
(1580149560, 1.10182, 1.10184, 1.10176, 1.10183, 25, 3, 0)
(1580149620, 1.10183, 1.10187, 1.10177, 1.10187, 49, 2, 0)
(1580149680, 1.10187, 1.1019, 1.1018, 1.10187, 53, 1, 0)
(1580149740, 1.10187, 1.10202, 1.10187, 1.10198, 28, 2, 0)
(1580149800, 1.10198, 1.10198, 1.10183, 1.10188, 39, 2, 0)
```

--------------------------------

### MQL5: Comparing Real Numbers using NormalizeDouble

Source: https://www.mql5.com/en/docs/basis/types/double

Introduces a second method for comparing real numbers for equality using the `NormalizeDouble` function. This approach normalizes the difference between two numbers to a specified precision and checks if it's effectively zero.

```MQL5
bool CompareDoubles(double number1,double number2)
{
if(NormalizeDouble(number1-number2,8)==0)
 return(true);
else
 return(false);
}
void OnStart()
{
double d_val=0.3;
float f_val=0.3;
if(CompareDoubles(d_val,f_val))
Print(d_val," equals ",f_val);
else
Print("Different: d_val = ",DoubleToString(d_val,16)," f_val = ",DoubleToString(f_val,16));
// Result: Different: d_val= 0.3000000000000000 f_val= 0.3000000119209290
```

--------------------------------

### Market Depth Data Structure in Python

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5marketbookget_py

Demonstrates the structure of market depth data as returned by the MetaTrader 5 Python package. The data is presented as a list of BookInfo objects, which are then converted to dictionaries for easier manipulation. Each dictionary represents a bid or ask order with price and volume information.

```python
# Example output structure for market depth
# (BookInfo(type=1, price=1.20038, volume=250, volume_dbl=250.0), BookInfo(type=1, price=1.20032, volume=100, volume_dbl=100.0)...
```

```python
# Dictionary representation of a bid order
{'type': 1, 'price': 1.20038, 'volume': 250, 'volume_dbl': 250.0}
```

```python
# Dictionary representation of an ask order
{'type': 2, 'price': 1.20026, 'volume': 36, 'volume_dbl': 36.0}
```

--------------------------------

### MQL5: Open Sell Position

Source: https://www.mql5.com/en/docs/constants/structures/mqltraderequest

This MQL5 code snippet demonstrates how to open a Sell position for a given symbol. It configures the trade request with TRADE_ACTION_DEAL, symbol, volume, order type as ORDER_TYPE_SELL, price (using SYMBOL_BID), deviation, and magic number. It also includes error reporting.

```MQL5
#define EXPERT_MAGIC 123456 // MagicNumber of the expert  
//+------------------------------------------------------------------+  
//| Opening Sell position |  
//+------------------------------------------------------------------+  
void OnStart()  
{  
//--- declare and initialize the trade request and result of trade request  
MqlTradeRequest request={};  
MqlTradeResult result={};  
//--- parameters of request  
request.action =TRADE_ACTION_DEAL; // type of trade operation  
request.symbol =Symbol(); // symbol  
request.volume =0.2; // volume of 0.2 lot  
request.type =ORDER_TYPE_SELL; // order type  
request.price =SymbolInfoDouble(Symbol(),SYMBOL_BID); // price for opening  
request.deviation=5; // allowed deviation from the price  
request.magic =EXPERT_MAGIC; // MagicNumber of the order  
//--- send the request  
if(!OrderSend(request,result))  
PrintFormat("OrderSend error %d",GetLastError()); // if unable to send the request, output the error code  
//--- information about the operation  
PrintFormat("retcode=%u deal=%I64u order=%I64u",result.retcode,result.deal,result.order);  
}
```

--------------------------------

### Python: Open and Close Trade using MetaTrader5 API

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5ordersend_py

This Python script utilizes the MetaTrader5 library to perform trading operations. It first ensures a symbol is visible and selectable, then places a buy order with specified parameters (lot size, price, stop-loss, take-profit, deviation). After a brief pause, it proceeds to close the opened position by sending a sell order. The script logs detailed results and error codes for each step, concluding with a shutdown of the MetaTrader5 connection.

```python
# if the symbol is unavailable in MarketWatch, add it
if not symbol_info.visible:
print(symbol, "is not visible, trying to switch on")
if not mt5.symbol_select(symbol,True):
print("symbol_select({}}}) failed, exit",symbol)
mt5.shutdown()
quit()

lot = 0.1
point = mt5.symbol_info(symbol).point
price = mt5.symbol_info_tick(symbol).ask
deviation = 20
request = {
"action": mt5.TRADE_ACTION_DEAL,
"symbol": symbol,
"volume": lot,
"type": mt5.ORDER_TYPE_BUY,
"price": price,
"sl": price - 100 * point,
"tp": price + 100 * point,
"deviation": deviation,
"magic": 234000,
"comment": "python script open",
"type_time": mt5.ORDER_TIME_GTC,
"type_filling": mt5.ORDER_FILLING_RETURN,
}

# send a trading request
result = mt5.order_send(request)
# check the execution result
print("1. order_send(): by {} {} lots at {} with deviation={}"
      " points".format(symbol,lot,price,deviation));
if result.retcode != mt5.TRADE_RETCODE_DONE:
print("2. order_send failed, retcode={}".format(result.retcode))
# request the result as a dictionary and display it element by element
result_dict=result._asdict()
for field in result_dict.keys():
print(" {}={}".format(field,result_dict[field]))
# if this is a trading request structure, display it element by element as well
if field=="request":
traderequest_dict=result_dict[field]._asdict()
for tradereq_filed in traderequest_dict:
print(" traderequest: {}={}".format(tradereq_filed,traderequest_dict[tradereq_filed]))
print("shutdown() and quit")
mt5.shutdown()
quit()

print("2. order_send done, ", result)
print(" opened position with POSITION_TICKET={}".format(result.order))
print(" sleep 2 seconds before closing position #{}"
      
```

--------------------------------

### Retrieve and Print MarketBookGet DOM Data (MQL5)

Source: https://www.mql5.com/en/docs/marketinformation/marketbookget

This MQL5 code snippet demonstrates how to retrieve Depth of Market (DOM) data for the current symbol using MarketBookGet and then prints the price, volume, and type of each DOM record. It checks for successful retrieval before iterating through the data. Ensure MarketBookAdd has been called previously for the symbol.

```MQL5
MqlBookInfo priceArray[];
bool getBook = MarketBookGet(NULL, priceArray);

if (getBook)
{
    int size = ArraySize(priceArray);
    Print("MarketBookInfo for ", Symbol());
    for (int i = 0; i < size; i++)
    {
        Print(i + ":", priceArray[i].price
        + " Volume = " + priceArray[i].volume,
        " type = ", priceArray[i].type);
    }
}
else
{
    Print("Could not get contents of the symbol DOM ", Symbol());
}
```

--------------------------------

### MQL5 Matrix Comparison and Result Verification

Source: https://www.mql5.com/en/docs/opencl/clbufferwrite

Compares the results of matrix multiplication obtained through different methods (naive, MatMul, and OpenCL) to verify accuracy. It calculates the number of discrepancies between the matrices using a specified tolerance.

```MQL5
//--- compare all obtained result matrices with each other   
Print("How many discrepancy errors are there between result matrices?");   
ulong errors=matrix_naive.Compare(matrix_matmul,(float)1e-12);
Print("matrix_direct.Compare(matrix_matmul,1e-12)=",errors);
errors=matrix_matmul.Compare(matrix_opencl,float(1e-12));
Print("matrix_matmul.Compare(matrix_opencl,1e-12)=",errors);
```

--------------------------------

### MQL5 Event Handling with OnChartEvent

Source: https://www.mql5.com/en/docs/basis/function/events

Illustrates how to handle different chart events within the OnChartEvent function in MQL5. Each event type (e.g., keydown, mouse move, object creation) is associated with specific values for the 'id', 'lparam', 'dparam', and 'sparam' parameters, enabling distinct processing logic for each interaction.

```MQL5
// Example handling for CHARTEVENT_KEYDOWN
if (id == CHARTEVENT_KEYDOWN)
{
    int key_code = (int)lparam;
    int repeat_count = (int)lparam; // Note: lparam is used for both key_code and repeat_count in some contexts, review documentation
    string key_status_mask = sparam;
    // Process key press event...
}

// Example handling for CHARTEVENT_MOUSE_MOVE
if (id == CHARTEVENT_MOUSE_MOVE)
{
    int x_coord = (int)lparam;
    int y_coord = (int)dparam;
    string mouse_button_mask = sparam;
    // Process mouse move event...
}

// Example handling for CHARTEVENT_OBJECT_CREATE
if (id == CHARTEVENT_OBJECT_CREATE)
{
    string object_name = sparam;
    // Process object creation event...
}

// Example handling for CHARTEVENT_CHART_CHANGE
if (id == CHARTEVENT_CHART_CHANGE)
{
    // Process chart change event...
}

// Example handling for custom events
if (id >= CHARTEVENT_CUSTOM)
{
    long custom_lparam = lparam;
    double custom_dparam = dparam;
    string custom_sparam = sparam;
    // Process custom event...
}
```

--------------------------------

### Set DirectX Shader Inputs (MQL5)

Source: https://www.mql5.com/en/docs/directx/dxshaderinputsset

The DXShaderInputsSet function in MQL5 is used to assign input handles to a specified shader. It requires a shader handle and an array of input handles. The number of input handles must match the cbuffer objects declared in the shader. It returns a boolean indicating success or failure.

```MQL5
bool DXShaderInputsSet(
int shader, // shader handle   
const int& inputs[] // array of input handles   
);
```

--------------------------------

### Retrieve USDCAD Rate Data in MQL5

Source: https://www.mql5.com/en/docs/python_metatrader5

This code snippet fetches historical rate data for USDCAD using the `eurcad_rates` function in MQL5. It retrieves a specified quantity of rate bars, each containing timestamp, open, high, low, close, volume, spread, and real volume.

```mql5
eurcad_rates( 1441 )
(1580122800, 1.45321, 1.45329, 1.4526, 1.4528, 146, 15, 0)
(1580122860, 1.4528, 1.45315, 1.45274, 1.45301, 93, 15, 0)
(1580122920, 1.453, 1.45304, 1.45264, 1.45264, 82, 15, 0)
(1580122980, 1.45263, 1.45279, 1.45231, 1.45277, 109, 15, 0)
(1580123040, 1.45275, 1.4528, 1.45259, 1.45271, 53, 14, 0)
(1580123100, 1.45273, 1.45285, 1.45269, 1.4528, 62, 16, 0)
(1580123160, 1.4528, 1.45284, 1.45267, 1.45282, 64, 14, 0)
(1580123220, 1.45282, 1.45299, 1.45261, 1.45272, 48, 14, 0)
(1580123280, 1.45272, 1.45275, 1.45255, 1.45275, 74, 14, 0)
(1580123340, 1.45275, 1.4528, 1.4526, 1.4528, 94, 13, 0)
```

--------------------------------

### MQL5 CTrade Class for Pending Order Placement

Source: https://www.mql5.com/en/docs/constants/structures/mqltradetransaction

Demonstrates how to use the CTrade class in MQL5 to asynchronously place a pending Buy Stop order. It covers initialization, setting the expert magic number, enabling asynchronous mode, and handling the trade request result. Dependencies include the CTrade class from the Trade.mqh library. Inputs are minimal, focusing on order parameters.

```MQL5
#include <Trade\Trade.mqh>
CTrade trade;

int OnInit()
{
  trade.SetExpertMagicNumber(1234567);
  trade.SetAsyncMode(true);
  return(INIT_SUCCEEDED);
}

void OnTick()
{
  double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
  double buy_stop_price = NormalizeDouble(ask + 1000 * _Point, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
  bool res = trade.BuyStop(0.1, buy_stop_price, _Symbol);
  if (res)
  {
    MqlTradeResult trade_result;
    trade.Result(trade_result);
    uint request_id = trade_result.request_id;
    Print("Request has been sent to set a pending order. Request_ID=", request_id);
  }
}
```

--------------------------------

### Create DirectX Buffer

Source: https://www.mql5.com/en/docs/directx/dxcontextcreate

Creates a vertex or index buffer for rendering. Buffers are associated with the graphics context they are created in and store vertex data or indices. Requires a valid context handle.

```MQL5
int DXBufferCreate(
  int context_handle, // handle of the graphic context
  uint size,          // size of the buffer in bytes
  uint format,        // buffer usage format (e.g., VERTEX_BUFFER, INDEX_BUFFER)
  uint bind_flags     // bind flags (e.g., BIND_SHADER_RESOURCE, BIND_UNORDERED_ACCESS)
);

```

--------------------------------

### Define MQL5 Class Methods Inline and Externally

Source: https://www.mql5.com/en/docs/basis/types/classes

Demonstrates defining MQL5 class methods both directly within the class declaration (inline) and separately using the scope resolution operator. This includes constructors and member functions with varying complexity.

```MQL5
class CTetrisShape   
{
protected:
int m_type;
int m_xpos;
int m_ypos;
int m_xsize;
int m_ysize;
int m_prev_turn;
int m_turn;
int m_right_border;
public:
void CTetrisShape();
void SetRightBorder(int border) { m_right_border=border; }
void SetYPos(int ypos) { m_ypos=ypos; }
void SetXPos(int xpos) { m_xpos=xpos; }
int GetYPos() { return(m_ypos); }
int GetXPos() { return(m_xpos); }
int GetYSize() { return(m_ysize); }
int GetXSize() { return(m_xsize); }
int GetType() { return(m_type); }
void Left() { m_xpos-=SHAPE_SIZE; }
void Right() { m_xpos+=SHAPE_SIZE; }
void Rotate() { m_prev_turn=m_turn; if(++m_turn>3) m_turn=0; }
virtual void Draw() { return; }
virtual bool CheckDown(int& pad_array[]);
virtual bool CheckLeft(int& side_row[]);
virtual bool CheckRight(int& side_row[]);
};

//+------------------------------------------------------------------+
//| Constructor of the basic class |
//+------------------------------------------------------------------+
void CTetrisShape::CTetrisShape()
{
m_type=0;
m_ypos=0;
m_xpos=0;
m_xsize=SHAPE_SIZE;
m_ysize=SHAPE_SIZE;
m_prev_turn=0;
m_turn=0;
m_right_border=0;
}

//+------------------------------------------------------------------+
//| Checking ability to move down (for the stick and cube) |
//+------------------------------------------------------------------+
bool CTetrisShape::CheckDown(int& pad_array[])
{
int i,xsize=m_xsize/SHAPE_SIZE;
//---
for(i=0; i<xsize; i++)
{
if(m_ypos+m_ysize>=pad_array[i]) return(false);
}
//---
return(true);
}

```

--------------------------------

### copy_rates_from

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5copyratesfrom_py

Retrieves historical bar data for a given financial instrument, timeframe, and date range from the MetaTrader 5 terminal.

```APIDOC
## POST /copy_rates_from

### Description
Retrieves historical bar data (OHLCV, spread, volume) for a specified financial instrument and timeframe, starting from a given date and for a defined number of bars.

### Method
POST

### Endpoint
/copy_rates_from

### Parameters
#### Path Parameters
None

#### Query Parameters
None

#### Request Body
- **symbol** (string) - Required - The financial instrument name (e.g., "EURUSD").
- **timeframe** (enum) - Required - The timeframe for the bars (e.g., mt5.TIMEFRAME_H4).
- **date_from** (datetime or int) - Required - The opening date of the first bar. Can be a datetime object or seconds since 1970-01-01.
- **count** (int) - Required - The number of bars to retrieve.

### Request Example
```json
{
  "symbol": "EURUSD",
  "timeframe": "TIMEFRAME_H4",
  "date_from": "2020-01-10T00:00:00Z",
  "count": 10
}
```

### Response
#### Success Response (200)
- **rates** (numpy.ndarray) - An array containing bar data with columns: time, open, high, low, close, tick_volume, spread, real_volume. Returns None if an error occurs.

#### Response Example
```json
{
  "rates": [
    {"time": 1578595200, "open": 1.1123, "high": 1.1130, "low": 1.1115, "close": 1.1125, "tick_volume": 100, "spread": 10, "real_volume": 50},
    {"time": 1578602400, "open": 1.1125, "high": 1.1140, "low": 1.1120, "close": 1.1135, "tick_volume": 120, "spread": 12, "real_volume": 60}
    // ... more bars
  ]
}
```

### Error Handling
- Returns `None` for the `rates` value in case of an error. Error details can be retrieved using `mt5.last_error()`.
```

--------------------------------

### MQL5 Database Operations

Source: https://www.mql5.com/en/docs/database

Provides a comprehensive set of functions for interacting with SQLite databases in MQL5. These functions allow for database creation, data manipulation (insert, update, delete), data retrieval via SQL queries, transaction management for bulk operations, and data import/export. It also includes utilities for checking table existence and retrieving column information.

```MQL5
bool DatabaseOpen(string name);
bool DatabaseClose();
bool DatabaseImport(string name, string table_name);
bool DatabaseExport(string name, string table_name_or_query);
bool DatabasePrint(string name, string table_name_or_query);
bool DatabaseTableExists(string table_name);
long DatabaseExecute(string query);
ulong DatabasePrepare(string query);
void DatabaseReset(ulong request_id);
bool DatabaseBind(ulong request_id, int column_index, any value);
bool DatabaseBindArray(ulong request_id, int column_index, any array[]);
bool DatabaseRead(ulong request_id);
bool DatabaseReadBind(ulong request_id, any &structure[]);
void DatabaseFinalize(ulong request_id);
void DatabaseTransactionBegin();
bool DatabaseTransactionCommit();
bool DatabaseTransactionRollback();
int DatabaseColumnsCount(ulong request_id);
string DatabaseColumnName(ulong request_id, int column_index);
int DatabaseColumnType(ulong request_id, int column_index);
int DatabaseColumnSize(ulong request_id, int column_index);
string DatabaseColumnText(ulong request_id, int column_index);
long DatabaseColumnInteger(ulong request_id, int column_index);
long DatabaseColumnLong(ulong request_id, int column_index);
double DatabaseColumnDouble(ulong request_id, int column_index);
any DatabaseColumnBlob(ulong request_id, int column_index);
```

--------------------------------

### Create DirectX Texture

Source: https://www.mql5.com/en/docs/directx/dxcontextcreate

Creates a texture for use in rendering. Textures can be used as input for shaders or as render targets. They are associated with the graphics context. Requires a valid context handle.

```MQL5
int DXTextureCreate(
  int context_handle, // handle of the graphic context
  uint width,         // texture width in pixels
  uint height,        // texture height in pixels
  uint format,        // texture format (e.g., FORMAT_R8G8B8A8_UNORM)
  uint bind_flags     // bind flags (e.g., BIND_SHADER_RESOURCE, BIND_RENDER_TARGET)
);

```

--------------------------------

### Handle MQL5 Trade Return Codes (MQL5)

Source: https://www.mql5.com/en/docs/constants/structures/mqltraderesult

This snippet demonstrates handling different trade return codes within an MQL5 script. It includes specific checks for TRADE_RETCODE_INVALID_VOLUME and TRADE_RETCODE_NO_MONEY, along with a default case for other errors. The function returns boolean values indicating success or failure and utilizes Print() for debugging output.

```MQL5
Print("TRADE_RETCODE_INVALID_VOLUME");
Print("request.volume = ",request.volume," result.volume = ",
result.volume);
break;
}
//--- not enough money for a trade operation
case 10019:
{
Print("TRADE_RETCODE_NO_MONEY");
Print("request.volume = ",request.volume," result.volume = ",
result.volume," result.comment = ",result.comment);
break;
}
//--- some other reason, output the server response code
default:
{
Print("Other answer = ",answer);
}
}
//--- notify about the unsuccessful result of the trade request by returning false
return(false);
}
//--- OrderSend() returns true - repeat the answer
return(true);
}
```

--------------------------------

### Initialize iBands Indicator in MQL5

Source: https://www.mql5.com/en/docs/indicators/ibands

Initializes the iBands indicator by creating a handle. It handles both direct iBands calls and using IndicatorCreate for more complex parameter passing. Returns INIT_FAILED on error.

```mql5
//--- create handle of the indicator   
if(type==Call_iBands)   
handle=iBands(name,period,bands_period,bands_shift,deviation,applied_price);   
else   
{   
//--- fill the structure with parameters of the indicator   
MqlParam pars[4];   
//--- period of ma   
pars[0].type=TYPE_INT;   
pars[0].integer_value=bands_period;   
//--- shift   
pars[1].type=TYPE_INT;   
pars[1].integer_value=bands_shift;   
//--- number of standard deviation   
pars[2].type=TYPE_DOUBLE;   
pars[2].double_value=deviation;   
//--- type of price   
pars[3].type=TYPE_INT;   
pars[3].integer_value=applied_price;   
handle=IndicatorCreate(name,period,IND_BANDS,4,pars);   
}   
//--- if the handle is not created   
if(handle==INVALID_HANDLE)   
{   
//--- tell about the failure and output the error code   
PrintFormat("Failed to create handle of the iBands indicator for the symbol %s/%s, error code %d",   
name,   
EnumToString(period),   
GetLastError());   
//--- the indicator is stopped early   
return(INIT_FAILED);   
}   
//--- show the symbol/timeframe the Bollinger Bands indicator is calculated for   
short_name=StringFormat("iBands(%s/%s, %d,%d,%G,%s)",name,EnumToString(period),   
bands_period,bands_shift,deviation,EnumToString(applied_price));   
IndicatorSetString(INDICATOR_SHORTNAME,short_name);   
//--- normal initialization of the indicator    
return(INIT_SUCCEEDED);   
}
```

--------------------------------

### MQL5: Demonstrating Double Precision Floating-Point Values

Source: https://www.mql5.com/en/docs/basis/types/double

This MQL5 code snippet illustrates the conversion of various double-precision floating-point values, including special numbers like NaN and Infinity, into their hexadecimal representations. It utilizes custom structures to hold and manipulate these values before printing them.

```MQL5
struct str1
{
long l;
double d;
};
struct str2
{
long l;
};

//--- Start
str1 s1;
str2 s2;
//---
s1.d=MathArcsin(2.0); // Get the invalid number -1.#IND
s2=s1;
printf("1. %f %I64X",s1.d,s2.l);
//---
s2.l=0xFFFF000000000000; // invalid number -1.#QNAN
s1=s2;
printf("2. %f %I64X",s1.d,s2.l);
//---
s2.l=0x7FF7000000000000; // greatest non-number SNaN
s1=s2;
printf("3. %f %I64X",s1.d,s2.l);
//---
s2.l=0x7FF8000000000000; // smallest non-number QNaN
s1=s2;
printf("4. %f %I64X",s1.d,s2.l);
//---
s2.l=0x7FFF000000000000; // greatest non-number QNaN
s1=s2;
printf("5. %f %I64X",s1.d,s2.l);
//---
s2.l=0x7FF0000000000000; // Positive infinity 1.#INF and smallest non-number SNaN
s1=s2;
printf("6. %f %I64X",s1.d,s2.l);
//---
s2.l=0xFFF0000000000000; // Negative infinity -1.#INF
s1=s2;
printf("7. %f %I64X",s1.d,s2.l);
//---
s2.l=0x8000000000000000; // Negative zero -0.0
s1=s2;
printf("8. %f %I64X",s1.d,s2.l);
//---
s2.l=0x3FE0000000000000; // 0.5
s1=s2;
printf("9. %f %I64X",s1.d,s2.l);
//---
s2.l=0x3FF0000000000000; // 1.0
s1=s2;
printf("10. %f %I64X",s1.d,s2.l);
//---
s2.l=0x7FEFFFFFFFFFFFFF; // Greatest normalized number (MAX_DBL)
s1=s2;
printf("11. %.16e %I64X",s1.d,s2.l);
//---
s2.l=0x0010000000000000; // Smallest positive normalized (MIN_DBL)
s1=s2;
printf("12. %.16e %.16I64X",s1.d,s2.l);
//---
s1.d=0.7; // Show that the number of 0.7 - endless fraction
s2=s1;
printf("13. %.16e %.16I64X",s1.d,s2.l);
/*
1. -1.#IND00 FFF8000000000000
2. -1.#QNAN0 FFFF000000000000
3. 1.#SNAN0 7FF7000000000000
4. 1.#QNAN0 7FF8000000000000
5. 1.#QNAN0 7FFF000000000000
6. 1.#INF00 7FF0000000000000
7. -1.#INF00 FFF0000000000000
8. -0.000000 8000000000000000
9. 0.500000 3FE0000000000000
10. 1.000000 3FF0000000000000
11. 1.7976931348623157e+308 7FEFFFFFFFFFFFFF
12. 2.2250738585072014e-308 0010000000000000
13. 6.9999999999999996e-001 3FE6666666666666
*/

```

--------------------------------

### Generate Beta Distribution Random Numbers (MQL5)

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/beta

Generates a sample of pseudorandom numbers distributed according to the beta distribution law. It takes the shape parameters (alpha and beta), the number of values to generate, and an output array as input. This is useful for simulations and statistical analysis.

```MQL5
#include <Math\Stat\Beta.mqh>
#include <Math\Stat\Math.mqh>

input double alpha=2; // the first parameter of beta distribution (shape1)
input double beta=5; // the second parameter of beta distribution (shape2)

void OnStart()
{
   long chart=0;
   string name="GraphicNormal";
   int n=1000000; // the number of values in the sample
   int ncells=51; // the number of intervals in the histogram
   double x[]; // centers of the histogram intervals
   double y[]; // the number of values from the sample falling within the interval
   double data[]; // sample of random values
   double max,min; // the maximum and minimum values in the sample
   
   // obtain a sample from the beta distribution
   MathRandomBeta(alpha,beta,n,data);
   
   // Further processing and visualization code would follow...
}
```

--------------------------------

### MQL5 Structure with Member Order and 4-Byte Alignment

Source: https://www.mql5.com/en/docs/basis/types/classes

This MQL5 code snippet defines a structure with members sorted by type size (ascending) and applies 4-byte alignment. It demonstrates how member order can influence structure padding and overall size, even with the same alignment setting. The output shows the sizes of individual members.

```MQL5
//+------------------------------------------------------------------+
//| Script program start function |
//+------------------------------------------------------------------+
void OnStart()
{
//--- simple structure aligned to the 4-byte boundary
struct CharShortInt pack(4)
{
char c; // sizeof(char)=1
short s; // sizeof(short)=2
int i; // sizeof(double)=4
};

//--- declare a simple structure instance 
CharShortInt ch_sh_in;

//--- display the size of each structure member
Print("sizeof(ch_sh_in.c)=",sizeof(ch_sh_in.c));
// Additional print statements for 's' and 'i' would typically follow here.
```

--------------------------------

### Create DirectX Input Layout

Source: https://www.mql5.com/en/docs/directx/dxcontextcreate

Creates an input layout object that defines the vertex data structure for a shader. This is crucial for binding vertex buffers to shader input. Requires a valid context handle.

```MQL5
int DXInputCreate(
  int context_handle, // handle of the graphic context
  int shader_handle,  // handle of the shader
  int input_layout[]  // array defining the input layout elements
);

```

--------------------------------

### Set DirectX Input Layout

Source: https://www.mql5.com/en/docs/directx/dxcontextcreate

Binds an input layout to the graphics pipeline for the current rendering pass. This tells the GPU how to interpret the vertex data from the bound vertex buffer. Requires a valid context handle.

```MQL5
void DXInputSet(
  int context_handle, // handle of the graphic context
  int input_layout_handle // handle of the input layout
);

```

--------------------------------

### SQL Mathematical Functions in MQL5

Source: https://www.mql5.com/en/docs/database

Illustrates the application of various mathematical functions within SQL queries in MQL5. This includes trigonometric, logarithmic, exponential, rounding, and other common mathematical operations that can be performed on data stored in the database.

```SQL
SELECT acos(column_name) FROM table_name;
SELECT acosh(column_name) FROM table_name;
SELECT asin(column_name) FROM table_name;
SELECT asinh(column_name) FROM table_name;
SELECT atan(column_name) FROM table_name;
SELECT atan2(column_x, column_y) FROM table_name;
SELECT atanh(column_name) FROM table_name;
SELECT ceil(column_name) FROM table_name;
SELECT ceiling(column_name) FROM table_name;
SELECT cos(column_name) FROM table_name;
SELECT cosh(column_name) FROM table_name;
SELECT degrees(column_name) FROM table_name;
SELECT exp(column_name) FROM table_name;
SELECT floor(column_name) FROM table_name;
SELECT ln(column_name) FROM table_name;
SELECT log(base, column_name) FROM table_name;
SELECT log(column_name) FROM table_name;
SELECT log10(column_name) FROM table_name;
SELECT log2(column_name) FROM table_name;
SELECT mod(column_x, column_y) FROM table_name;
SELECT pi() FROM table_name;
SELECT pow(base, exponent) FROM table_name;
SELECT power(base, exponent) FROM table_name;
SELECT radians(column_name) FROM table_name;
SELECT sin(column_name) FROM table_name;
SELECT sinh(column_name) FROM table_name;
SELECT sqrt(column_name) FROM table_name;
SELECT tan(column_name) FROM table_name;
SELECT tanh(column_name) FROM table_name;
SELECT trunc(column_name) FROM table_name;
```

--------------------------------

### Calculate Beta Distribution Probability Density (MQL5)

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/beta

Calculates the probability density function (PDF) of the beta distribution. It takes an array of x-values, the distribution's shape parameters (alpha and beta), and a flag for cumulative calculation as input. The output is an array containing the corresponding density values.

```MQL5
#include <Math\Stat\Beta.mqh>
#include <Math\Stat\Math.mqh>

input double alpha=2; // the first parameter of beta distribution (shape1)
input double beta=5; // the second parameter of beta distribution (shape2)

void OnStart()
{
   // ... (previous code for generating data and calculating histogram) ...
   
   double min, max;
   // Assume min and max are already calculated from sample data
   // For example:
   // double data[]; MathRandomBeta(alpha,beta,1000000,data);
   // min = data[ArrayMinimum(data)];
   // max = data[ArrayMaximum(data)];
   
   double step;
   GetMaxMinStepValues(max,min,step);
   step=MathMin(step,(max-min)/ncells);
   
   double x2[]; // theoretically calculated x values
   double y2[]; // theoretically calculated density values
   
   MathSequence(min,max,step,x2);
   MathProbabilityDensityBeta(x2,alpha,beta,false,y2);
   
   // ... (rest of the visualization code) ...
}
```

--------------------------------

### Set DirectX Shader Layout

Source: https://www.mql5.com/en/docs/directx/dxcontextcreate

Defines the layout of shader resources (like textures and buffers) that will be bound to the shader. This specifies which slots in the shader will receive which resources. Requires a valid context handle.

```MQL5
void DXShaderSetLayout(
  int context_handle, // handle of the graphic context
  int shader_handle,  // handle of the shader
  int layout_handle   // handle of the shader layout
);

```

--------------------------------

### Release DirectX Resource

Source: https://www.mql5.com/en/docs/directx/dxcontextcreate

Releases a DirectX graphics resource (context, buffer, texture, shader, etc.), freeing up associated GPU memory. It's crucial to call this for all created resources when they are no longer needed to prevent memory leaks. Requires a valid handle to the resource.

```MQL5
void DXRelease(
  int handle // handle of the resource to release
);

```

--------------------------------

### Draw Indexed Primitives with DirectX

Source: https://www.mql5.com/en/docs/directx/dxcontextcreate

Draws primitives using an index buffer. This allows for more efficient rendering by reusing vertices. Requires a valid context handle and a bound index buffer.

```MQL5
void DXDrawIndexed(
  int context_handle, // handle of the graphic context
  uint index_count,   // number of indices to use
  uint start_index,   // index of the first index to use
  uint base_vertex    // value added to each index before accessing vertex data
);

```

--------------------------------

### MQL5 Class Definition with Access Specifiers

Source: https://www.mql5.com/en/docs/basis/types/classes

Demonstrates the declaration of class members and methods using public, private, and protected access specifiers in MQL5. Private members are only accessible within the class, protected members are accessible within the class and its descendants, and public members are accessible from anywhere. Access specifiers end with a colon and can appear multiple times within a class definition.

```MQL5
class CTetrisField
{
private:
int m_score; // Score
int m_ypos; // Current position of the figures
int m_field[FIELD_HEIGHT][FIELD_WIDTH]; // Matrix of the well
int m_rows[FIELD_HEIGHT]; // Numbering of the well rows
int m_last_row; // Last free row
CTetrisShape *m_shape; // Tetris figure
bool m_bover; // Game over
public:
void CTetrisField() { m_shape=NULL; m_bover=false; }
void Init();
void Deinit();
void Down();
void Left();
void Right();
void Rotate();
void Drop();
private:
void NewShape();
void CheckAndDeleteRows();
void LabelOver();
};

```

--------------------------------

### SQL Statistical Functions in MQL5

Source: https://www.mql5.com/en/docs/database

Demonstrates the use of built-in statistical functions within SQL queries executed via MQL5. These functions allow for calculations such as mode, median, percentiles, standard deviation, and variance directly on database records.

```SQL
SELECT mode(column_name) FROM table_name;
SELECT median(column_name) FROM table_name;
SELECT percentile_25(column_name) FROM table_name;
SELECT percentile_75(column_name) FROM table_name;
SELECT percentile_90(column_name) FROM table_name;
SELECT percentile_95(column_name) FROM table_name;
SELECT percentile_99(column_name) FROM table_name;
SELECT stddev(column_name) FROM table_name;
SELECT stddev_samp(column_name) FROM table_name;
SELECT stddev_pop(column_name) FROM table_name;
SELECT variance(column_name) FROM table_name;
SELECT var_samp(column_name) FROM table_name;
SELECT var_pop(column_name) FROM table_name;
```

--------------------------------

### Configuring Indicator Properties in MQL5

Source: https://www.mql5.com/en/docs/customind

Shows how to set general indicator properties using IndicatorSetDouble, IndicatorSetInteger, and IndicatorSetString functions. These functions control aspects like the indicator's name, digits, and other global settings.

```mql5
void IndicatorSetDouble(int prop_id, double value);
void IndicatorSetInteger(int prop_id, long value);
void IndicatorSetString(int prop_id, const string &value);
```

--------------------------------

### DXInputSet

Source: https://www.mql5.com/en/docs/directx/dxinputset

Sets shader inputs by providing data for a specific input handle. This function is crucial for passing vertex attributes or uniform variables to shaders.

```APIDOC
## DXInputSet

### Description
Sets shader inputs by providing data for a specific input handle.

### Method
N/A (This is a function call within MQL5, not an HTTP API endpoint)

### Endpoint
N/A

### Parameters
#### Path Parameters
N/A

#### Query Parameters
N/A

#### Request Body
N/A

### Request Example
```mql
bool success = DXInputSet(input_handle, shader_data);
```

### Response
#### Success Response
- **bool** (boolean) - Returns `true` if the inputs were set successfully, `false` otherwise.

#### Response Example
```json
// Return value is a boolean
// true: successful operation
// false: failed operation
```

### Additional Information
- The `input` parameter is a handle obtained from `DXInputCreate()`.
- The `data` parameter is the actual data to be set for the shader input.
- Use `GetLastError()` to retrieve error codes upon failure.
```

--------------------------------

### MQL5 Lineage-Based Structure Copying (Animal, Dog, Cat)

Source: https://www.mql5.com/en/docs/basis/types/classes

Illustrates copying simple structures based on lineage. It shows that a descendant structure (e.g., `Dog`) can be assigned a value from an ancestor structure (e.g., `Animal`). However, direct copying between sibling descendant structures (e.g., `Cat` to `Dog`) is not allowed, even though they share a common ancestor.

```MQL5
//--- basic structure for describing animals
struct Animal
{
int head; // number of heads
int legs; // number of legs
int wings; // number of wings
bool tail; // tail
bool fly; // flying
bool swim; // swimming 
bool run; // running
};
//--- structure for describing dogs
struct Dog: Animal
{
bool hunting; // hunting breed
};
//--- structure for describing cats
struct Cat: Animal
{
bool home; // home breed
};
//--- create objects of child structures
Dog dog;
Cat cat;
//--- can be copied from ancestor to descendant (Animal ==> Dog)
dog=some_animal; // Assuming some_animal is an Animal object or compatible
dog.swim=true; // dogs can swim
//--- you cannot copy objects of child structures (Dog != Cat)
// cat=dog; // compiler returns an error

```

--------------------------------

### MQL5: Class Without Default Constructor - Compilation Error

Source: https://www.mql5.com/en/docs/basis/types/classes

Illustrates an MQL5 class `CFoo` that defines a parametric constructor but lacks a default constructor. Attempting to declare an array of `CFoo` objects (`CFoo badFoo[5];`) results in a compilation error, as the compiler cannot automatically initialize array elements without a default constructor.

```MQL5
//+------------------------------------------------------------------+
//| A class without a default constructor |
//+------------------------------------------------------------------+
class CFoo
{
string m_name;
public:
CFoo(string name) { m_name=name;}
};
//+------------------------------------------------------------------+
//| Script program start function |
//+------------------------------------------------------------------+
void OnStart()
{
//--- Get the "default constructor is not defined" error during compilation
CFoo badFoo[5];
}
```

--------------------------------

### MQL5 Function: GetTickDescription for MqlTick

Source: https://www.mql5.com/en/docs/series/copyticks

This MQL5 function generates a descriptive string for a given MqlTick structure. It parses tick flags to determine if it's a trade tick (Buy/Sell) or an info tick (Ask/Bid/Last/Volume) and formats the output accordingly. The function requires the MqlTick structure as input and returns a formatted string. The output format varies based on the tick type.

```MQL5
//+------------------------------------------------------------------+
//| Returns the string description of a tick |
//+------------------------------------------------------------------+
string GetTickDescription(MqlTick &tick)
{
string desc=StringFormat("%s.%03d ",
TimeToString(tick.time),tick.time_msc%1000);
//--- Checking flags
bool buy_tick=((tick.flags&TICK_FLAG_BUY)==TICK_FLAG_BUY);
bool sell_tick=((tick.flags&TICK_FLAG_SELL)==TICK_FLAG_SELL);
bool ask_tick=((tick.flags&TICK_FLAG_ASK)==TICK_FLAG_ASK);
bool bid_tick=((tick.flags&TICK_FLAG_BID)==TICK_FLAG_BID);
bool last_tick=((tick.flags&TICK_FLAG_LAST)==TICK_FLAG_LAST);
bool volume_tick=((tick.flags&TICK_FLAG_VOLUME)==TICK_FLAG_VOLUME);
//--- Checking trading flags in a tick first
if(buy_tick || sell_tick)
{
//--- Forming an output for the trading tick
desc=desc+(buy_tick?StringFormat("Buy Tick: Last=%G Volume=%d ",tick.last,tick.volume):"");
desc=desc+(sell_tick?StringFormat("Sell Tick: Last=%G Volume=%d ",tick.last,tick.volume):"");
desc=desc+(ask_tick?StringFormat("Ask=%G ",tick.ask):"");
desc=desc+(bid_tick?StringFormat("Bid=%G ",tick.ask):"");
desc=desc+"(Trade tick)";
}
else
{
//--- Form a different output for an info tick
desc=desc+(ask_tick?StringFormat("Ask=%G ",tick.ask):"");
desc=desc+(bid_tick?StringFormat("Bid=%G ",tick.ask):"");
desc=desc+(last_tick?StringFormat("Last=%G ",tick.last):"");
desc=desc+(volume_tick?StringFormat("Volume=%d ",tick.volume):"");
desc=desc+"(Info tick)";
}
//--- Returning tick description
return desc;
}

```

--------------------------------

### MQL5 Aggregate and Statistical Calculations

Source: https://www.mql5.com/en/docs/database

This snippet showcases MQL5 functions for performing aggregate and statistical calculations on a 'parent' column within the 'moz_bookmarks' table. It includes casting the average and median to integers, calculating the mode, and retrieving specific percentiles (90th, 95th, and 99th).

```MQL5
cast(avg(parent) as integer) as mean,
cast(median(parent) as integer) as median,
mode(parent) as mode,
percentile_90(parent) as p90,
percentile_95(parent) as p95,
percentile_99(parent) as p99
from moz_bookmarks;
```

--------------------------------

### Setting Indicator Buffers in MQL5

Source: https://www.mql5.com/en/docs/customind

Demonstrates how to set indicator data buffers using the SetIndexBuffer function. This is fundamental for storing and accessing indicator values. It requires specifying the buffer number, data array, and drawing style.

```mql5
bool SetIndexBuffer(int index, double &array[], int type=INDICATOR_DATA, int shift=0);
```

--------------------------------

### MQL5 OnTesterDeinit: Final Optimization Result Processing

Source: https://www.mql5.com/en/docs/basis/function/events

OnTesterDeinit() is called after Expert Advisor optimization is completed, handling the TesterDeinit event. It is used for any final processing of all collected optimization results.

```MQL5
void OnTesterDeinit()
{
  // Final processing of all optimization results
}
```

--------------------------------

### MQL5 Negative Binomial Distribution Calculations

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/negativebinomial

This snippet demonstrates how to use MQL5 functions to generate random numbers following a negative binomial distribution, calculate its probability density, and visualize the results using a histogram. It includes initialization of the random number generator and plotting of both sample data and theoretical distribution curves.

```MQL5
#include <Graphics\Graphic.mqh>
#include <Math\Stat\NegativeBinomial.mqh>
#include <Math\Stat\Math.mqh>

#property script_show_inputs

//--- input parameters
input double n_par=40; // the number of tests
input double p_par=0.75; // probability of success for each test

//+------------------------------------------------------------------+
//| Script program start function |
//+------------------------------------------------------------------+
void OnStart()
{
//--- hide the price chart
ChartSetInteger(0,CHART_SHOW,false);

//--- initialize the random number generator 
MathSrand(GetTickCount());

//--- generate a sample of the random variable
long chart=0;
string name="GraphicNormal";
int n=1000000; // the number of values in the sample
int ncells=19; // the number of intervals in the histogram
double x[]; // centers of the histogram intervals
double y[]; // the number of values from the sample falling within the interval
double data[]; // sample of random values
double max,min; // the maximum and minimum values in the sample

//--- obtain a sample from the negative binomial distribution
MathRandomNegativeBinomial(n_par,p_par,n,data);

//--- calculate the data to plot the histogram
CalculateHistogramArray(data,x,y,max,min,ncells);

//--- obtain the theoretically calculated data at the interval of [min,max]
double x2[];
double y2[];
MathSequence(0,n_par,1,x2);
MathProbabilityDensityNegativeBinomial(x2,n_par,p_par,false,y2);

//--- set the scale
double theor_max=y2[ArrayMaximum(y2)];
double sample_max=y[ArrayMaximum(y)];
double k=sample_max/theor_max;
for(int i=0; i<ncells; i++)
 y[i]/=k;

//--- output charts
CGraphic graphic;
if(ObjectFind(chart,name)<0)
 graphic.Create(chart,name,0,0,0,780,380);
else
 graphic.Attach(chart,name);

graphic.BackgroundMain(StringFormat("Negative Binomial distributionn n=%G p=%G",n_par,p_par));
graphic.BackgroundMainSize(16);

//--- plot all curves
graphic.CurveAdd(x,y,CURVE_HISTOGRAM,"Sample").HistogramWidth(6);

//--- and now plot the theoretical curve of the distribution density
graphic.CurveAdd(x2,y2,CURVE_LINES,"Theory").LinesSmooth(true);
graphic.CurvePlotAll();

//--- plot all curves
graphic.Update();
}

//+------------------------------------------------------------------+
//| Calculate frequencies for data set |
//+------------------------------------------------------------------+
bool CalculateHistogramArray(const double &data[],double &intervals[],double &frequency[],
 double &maxv,double &minv,const int cells=10)
{
if(cells<=1) return (false);
int size=ArraySize(data);
if(size<cells*10) return (false);

minv=data[ArrayMinimum(data)];
maxv=data[ArrayMaximum(data)];

double range=maxv-minv;
double width=range/cells;

if(width==0) return false;

ArrayResize(intervals,cells);
ArrayResize(frequency,cells);

//--- define the interval centers
for(int i=0; i<cells; i++)
{
 intervals[i]=minv+(i+0.5)*width;
 frequency[i]=0;
}

//--- fill the frequencies of falling within the interval
for(int i=0; i<size; i++)
{
 int ind=int((data[i]-minv)/width);
 if(ind>=cells) ind=cells-1;
 frequency[ind]++;
}

return (true);
}

```

--------------------------------

### Set DirectX Graphics Context Size

Source: https://www.mql5.com/en/docs/directx/dxcontextcreate

Sets the size of an existing graphics context. This function allows dynamic resizing of the rendering frame. Requires a valid context handle obtained from DXContextCreate.

```MQL5
void DXContextSetSize(
  int context_handle, // handle of the graphic context
  uint width,         // new width in pixels
  uint height         // new height in pixels
);

```

--------------------------------

### Calculate Margin for Trading Operations (Python)

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5ordercalcmargin_py

This Python code snippet demonstrates how to use the MetaTrader5 library to calculate the margin required for a buy order on various currency pairs. It initializes the connection, retrieves account information, iterates through a list of symbols, and calls `order_calc_margin` for each symbol using the current ask price.

```python
import MetaTrader5 as mt5

# display data on the MetaTrader 5 package
print("MetaTrader5 package author: ",mt5.__author__)
print("MetaTrader5 package version: ",mt5.__version__)

# establish connection to MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed, error code =",mt5.last_error())
    quit()

# get account currency
account_currency=mt5.account_info().currency
print("Account currency:",account_currency)

# arrange the symbol list
symbols=("EURUSD","GBPUSD","USDJPY", "USDCHF","EURJPY","GBPJPY")
print("Symbols to check margin:", symbols)
action=mt5.ORDER_TYPE_BUY
lot=0.1
for symbol in symbols:
    symbol_info=mt5.symbol_info(symbol)
    if symbol_info is None:
        print(symbol,"not found, skipped")
        continue
    if not symbol_info.visible:
        print(symbol, "is not visible, trying to switch on")
        if not mt5.symbol_select(symbol,True):
            print("symbol_select({}}}) failed, skipped",symbol)
            continue
    ask=mt5.symbol_info_tick(symbol).ask
    margin=mt5.order_calc_margin(action,symbol,lot,ask)
    if margin != None:
        print(" {} buy {} lot margin: {} {}".format(symbol,lot,margin,account_currency));
    else:
        print("order_calc_margin failed: , error code =", mt5.last_error())

# shut down connection to the MetaTrader 5 terminal
mt5.shutdown()
```

--------------------------------

### MQL5 Hypergeometric Distribution Functions

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/hypergeometric

This snippet includes MQL5 functions for calculating various aspects of the hypergeometric distribution. It requires the 'Hypergeometric.mqh' and 'Math.mqh' libraries. The functions operate on numerical inputs and can produce numerical outputs for probabilities, quantiles, and random numbers.

```MQL5
#include <Graphics\Graphic.mqh>
#include <Math\Stat\Hypergeometric.mqh>
#include <Math\Stat\Math.mqh>

#property script_show_inputs

//--- input parameters
input double m_par=60; // the total number of objects
input double k_par=30; // the number of objects with the desired characteristic
input double n_par=30; // the number of object draws

//+------------------------------------------------------------------+
//| Script program start function |
//+------------------------------------------------------------------+
void OnStart()
{
//--- hide the price chart
ChartSetInteger(0,CHART_SHOW,false);
//--- initialize the random number generator 
MathSrand(GetTickCount());
//--- generate a sample of the random variable
long chart=0;
string name="GraphicNormal";
int n=1000000; // the number of values in the sample
int ncells=15; // the number of intervals in the histogram
double x[]; // centers of the histogram intervals
double y[]; // the number of values from the sample falling within the interval
double data[]; // sample of random values
double max,min; // the maximum and minimum values in the sample
//--- obtain a sample from the hypergeometric distribution
MathRandomHypergeometric(m_par,k_par,n_par,n,data);
//--- calculate the data to plot the histogram
CalculateHistogramArray(data,x,y,max,min,ncells);
//--- obtain the sequence boundaries and the step for plotting the theoretical curve
double step;
GetMaxMinStepValues(max,min,step);
PrintFormat("max=%G min=%G",max,min);
//--- obtain the theoretically calculated data at the interval of [min,max]
double x2[];
double y2[];
MathSequence(0,n_par,1,x2);
MathProbabilityDensityHypergeometric(x2,m_par,k_par,n_par,false,y2);
//--- set the scale
double theor_max=y2[ArrayMaximum(y2)];
double sample_max=y[ArrayMaximum(y)];
double k=sample_max/theor_max;
for(int i=0; i<ncells; i++)
y[i]/=k;
//--- output charts
CGraphic graphic;
if(ObjectFind(chart,name)<0)
graphic.Create(chart,name,0,0,0,780,380);
else
graphic.Attach(chart,name);
graphic.BackgroundMain(StringFormat("Hypergeometric distribution m=%G k=%G n=%G",m_par,k_par,n_par));
graphic.BackgroundMainSize(16);
//--- plot all curves
graphic.CurveAdd(x,y,CURVE_HISTOGRAM,"Sample").HistogramWidth(6);
//--- and now plot the theoretical curve of the distribution density
graphic.CurveAdd(x2,y2,CURVE_LINES,"Theory").LinesSmooth(true);
graphic.CurvePlotAll();
//--- plot all curves
graphic.Update();
}
//+------------------------------------------------------------------+
//| Calculate frequencies for data set |
//+------------------------------------------------------------------+
bool CalculateHistogramArray(const double &data[],double &intervals[],double &frequency[],
 double &maxv,double &minv,const int cells=10)
{
if(cells<=1) return (false);
int size=ArraySize(data);
if(size<cells*10) return (false);
minv=data[ArrayMinimum(data)];
maxv=data[ArrayMaximum(data)];
double range=maxv-minv;
double width=range/cells;
if(width==0) return false;
ArrayResize(intervals,cells);
ArrayResize(frequency,cells);
//--- define the interval centers
for(int i=0; i<cells; i++)
{
intervals[i]=minv+(i+0.5)*width;
frequency[i]=0;
}
//--- fill the frequencies of falling within the interval
for(int i=0; i<size; i++)
{
int ind=int((data[i]-minv)/width);
if(ind>=cells) ind=cells-1;
frequency[ind]++;
}
return (true);
}

```

--------------------------------

### MQL5: Calculate Max, Min, and Step Values for Sequence Generation

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/hypergeometric

This function calculates the maximum value, minimum value, and step value for sequence generation. It normalizes these values based on the absolute range of the sequence to determine the precision. Dependencies include MQL5 built-in math functions like MathAbs, MathRound, MathLog10, NormalizeDouble, and MathPow. It takes three double references (maxv, minv, stepv) as input and modifies them in place.

```MQL5
//+------------------------------------------------------------------+
//| Calculates values for sequence generation |
//+------------------------------------------------------------------+
void GetMaxMinStepValues(double &maxv,double &minv,double &stepv)
{
//--- calculate the absolute range of the sequence to obtain the precision of normalization
double range=MathAbs(maxv-minv);
int degree=(int)MathRound(MathLog10(range));
//--- normalize the maximum and minimum values to the specified precision
maxv=NormalizeDouble(maxv,degree);
minv=NormalizeDouble(minv,degree);
//--- sequence generation step is also set based on the specified precision
stepv=NormalizeDouble(MathPow(10,-degree),degree);
if((maxv-minv)/stepv<10)
stepv/=10.;
}
```

--------------------------------

### Chart Operations Reference

Source: https://www.mql5.com/en/docs/chart_operations

This section details various MQL5 functions for interacting with and manipulating charts.

```APIDOC
## Chart Operations API

This API provides functions for managing and manipulating financial charts within the MQL5 environment.

### Asynchronous Operations
Functions like `ChartSetDouble`, `ChartSetInteger`, and `ChartSetString` are asynchronous. They queue update commands to the chart. Immediate updates are not guaranteed. Use `ChartRedraw()` for forced updates.

### Function Reference

- **`ChartApplyTemplate(chart_id, template_name)`**
  - **Description**: Applies a specific template from a specified file to the chart.
  - **Method**: N/A (MQL5 function)
  - **Parameters**:
    - `chart_id` (long) - The ID of the chart to apply the template to.
    - `template_name` (string) - The name of the template file.

- **`ChartSaveTemplate(chart_id, template_name)`**
  - **Description**: Saves the current chart settings in a template with a specified name.
  - **Method**: N/A (MQL5 function)
  - **Parameters**:
    - `chart_id` (long) - The ID of the chart to save.
    - `template_name` (string) - The name for the template file.

- **`ChartWindowFind(chart_id, indicator_name)`**
  - **Description**: Returns the number of a subwindow where an indicator is drawn.
  - **Method**: N/A (MQL5 function)
  - **Parameters**:
    - `chart_id` (long) - The ID of the chart.
    - `indicator_name` (string) - The short name of the indicator.
  - **Returns**: The subwindow index, or -1 if the indicator is not found.

- **`ChartTimePriceToXY(chart_id, subwindow, time, price, &x, &y)`**
  - **Description**: Converts the coordinates of a chart from the time/price representation to the X and Y coordinates.
  - **Method**: N/A (MQL5 function)
  - **Parameters**:
    - `chart_id` (long) - The ID of the chart.
    - `subwindow` (int) - The subwindow index.
    - `time` (datetime) - The time value.
    - `price` (double) - The price value.
    - `x` (int&, output) - Variable to store the X coordinate.
    - `y` (int&, output) - Variable to store the Y coordinate.

- **`ChartXYToTimePrice(chart_id, subwindow, x, y, &time, &price)`**
  - **Description**: Converts the X and Y coordinates on a chart to the time and price values.
  - **Method**: N/A (MQL5 function)
  - **Parameters**:
    - `chart_id` (long) - The ID of the chart.
    - `subwindow` (int) - The subwindow index.
    - `x` (int) - The X coordinate.
    - `y` (int) - The Y coordinate.
    - `time` (datetime&, output) - Variable to store the time value.
    - `price` (double&, output) - Variable to store the price value.

- **`ChartOpen(symbol, period)`**
  - **Description**: Opens a new chart with the specified symbol and period.
  - **Method**: N/A (MQL5 function)
  - **Parameters**:
    - `symbol` (string) - The symbol for the new chart.
    - `period` (ENUM_TIMEFRAMES) - The period for the new chart.
  - **Returns**: The ID of the newly opened chart, or -1 if an error occurs.

- **`ChartClose(chart_id)`**
  - **Description**: Closes the specified chart.
  - **Method**: N/A (MQL5 function)
  - **Parameters**:
    - `chart_id` (long) - The ID of the chart to close.

- **`ChartFirst()`**
  - **Description**: Returns the ID of the first chart of the client terminal.
  - **Method**: N/A (MQL5 function)
  - **Returns**: The ID of the first chart.

- **`ChartNext(chart_id)`**
  - **Description**: Returns the chart ID of the chart next to the specified one.
  - **Method**: N/A (MQL5 function)
  - **Parameters**:
    - `chart_id` (long) - The ID of the current chart.
  - **Returns**: The ID of the next chart, or -1 if there is no next chart.

- **`ChartSymbol(chart_id)`**
  - **Description**: Returns the symbol name of the specified chart.
  - **Method**: N/A (MQL5 function)
  - **Parameters**:
    - `chart_id` (long) - The ID of the chart.
  - **Returns**: The symbol name of the chart.

- **`ChartPeriod(chart_id)`**
  - **Description**: Returns the period value of the specified chart.
  - **Method**: N/A (MQL5 function)
  - **Parameters**:
    - `chart_id` (long) - The ID of the chart.
  - **Returns**: The period value (ENUM_TIMEFRAMES) of the chart.

- **`ChartRedraw(chart_id)`**
  - **Description**: Calls a forced redrawing of a specified chart.
  - **Method**: N/A (MQL5 function)
  - **Parameters**:
    - `chart_id` (long) - The ID of the chart to redraw.

- **`ChartSetDouble(chart_id, prop_id, value)`**
  - **Description**: Sets the double value for a corresponding property of the specified chart.
  - **Method**: N/A (MQL5 function)
  - **Parameters**:
    - `chart_id` (long) - The ID of the chart.
    - `prop_id` (ENUM_CHART_PROPERTY_DOUBLE) - The ID of the property to set.
    - `value` (double) - The new double value for the property.

- **`ChartSetInteger(chart_id, prop_id, value)`**
  - **Description**: Sets the integer value (datetime, int, color, bool or char) for a corresponding property of the specified chart.
  - **Method**: N/A (MQL5 function)
  - **Parameters**:
    - `chart_id` (long) - The ID of the chart.
    - `prop_id` (ENUM_CHART_PROPERTY_INTEGER) - The ID of the property to set.
    - `value` (long) - The new integer value for the property.

- **`ChartSetString(chart_id, prop_id, value)`**
  - **Description**: Sets the string value for a corresponding property of the specified chart.
  - **Method**: N/A (MQL5 function)
  - **Parameters**:
    - `chart_id` (long) - The ID of the chart.
    - `prop_id` (ENUM_CHART_PROPERTY_STRING) - The ID of the property to set.
    - `value` (string) - The new string value for the property.

- **`ChartGetDouble(chart_id, prop_id)`**
  - **Description**: Returns the double value property of the specified chart.
  - **Method**: N/A (MQL5 function)
  - **Parameters**:
    - `chart_id` (long) - The ID of the chart.
    - `prop_id` (ENUM_CHART_PROPERTY_DOUBLE) - The ID of the property to get.
  - **Returns**: The double value of the property.

- **`ChartGetInteger(chart_id, prop_id)`**
  - **Description**: Returns the integer value property of the specified chart.
  - **Method**: N/A (MQL5 function)
  - **Parameters**:
    - `chart_id` (long) - The ID of the chart.
    - `prop_id` (ENUM_CHART_PROPERTY_INTEGER) - The ID of the property to get.
  - **Returns**: The integer value of the property.

- **`ChartGetString(chart_id, prop_id)`**
  - **Description**: Returns the string value property of the specified chart.
  - **Method**: N/A (MQL5 function)
  - **Parameters**:
    - `chart_id` (long) - The ID of the chart.
    - `prop_id` (ENUM_CHART_PROPERTY_STRING) - The ID of the property to get.
  - **Returns**: The string value of the property.

- **`ChartNavigate(chart_id, position, shift)`**
  - **Description**: Performs a shift of the specified chart by the specified number of bars relative to the specified position in the chart.
  - **Method**: N/A (MQL5 function)
  - **Parameters**:
    - `chart_id` (long) - The ID of the chart.
    - `position` (long) - The starting position for the shift.
    - `shift` (long) - The number of bars to shift by.

- **`ChartID()`**
  - **Description**: Returns the ID of the current chart.
  - **Method**: N/A (MQL5 function)
  - **Returns**: The ID of the current chart.

- **`ChartIndicatorAdd(chart_id, subwindow, indicator_handle)`**
  - **Description**: Adds an indicator with the specified handle into a specified chart window.
  - **Method**: N/A (MQL5 function)
  - **Parameters**:
    - `chart_id` (long) - The ID of the chart.
    - `subwindow` (int) - The subwindow index to add the indicator to.
    - `indicator_handle` (int) - The handle of the indicator to add.
  - **Returns**: Index of the added indicator, or -1 if an error occurs.

- **`ChartIndicatorDelete(chart_id, subwindow, index)`**
  - **Description**: Removes an indicator by its index from the specified chart window.
  - **Method**: N/A (MQL5 function)
  - **Parameters**:
    - `chart_id` (long) - The ID of the chart.
    - `subwindow` (int) - The subwindow index.
    - `index` (int) - The index of the indicator to delete.

- **`ChartIndicatorGet(chart_id, subwindow, short_name)`**
  - **Description**: Returns the handle of the indicator with the specified short name in the specified chart window.
  - **Method**: N/A (MQL5 function)
  - **Parameters**:
    - `chart_id` (long) - The ID of the chart.
    - `subwindow` (int) - The subwindow index.
    - `short_name` (string) - The short name of the indicator.
  - **Returns**: The indicator handle, or -1 if not found.

- **`ChartIndicatorName(chart_id, subwindow, index)`**
  - **Description**: Returns the short name of the indicator by the number in the indicators list on the specified chart window.
  - **Method**: N/A (MQL5 function)
  - **Parameters**:
    - `chart_id` (long) - The ID of the chart.
    - `subwindow` (int) - The subwindow index.
    - `index` (int) - The index of the indicator in the list.
  - **Returns**: The short name of the indicator.

- **`ChartIndicatorsTotal(chart_id, subwindow)`**
  - **Description**: Returns the number of all indicators applied to the specified chart window.
  - **Method**: N/A (MQL5 function)
  - **Parameters**:
    - `chart_id` (long) - The ID of the chart.
    - `subwindow` (int) - The subwindow index.
  - **Returns**: The total number of indicators in the specified subwindow.

- **`ChartWindowOnDropped()`**
  - **Description**: Returns the number (index) of the chart subwindow the Expert Advisor or script has been dropped to.
  - **Method**: N/A (MQL5 function)
  - **Returns**: The subwindow index.

- **`ChartPriceOnDropped()`**
  - **Description**: Returns the price coordinate of the chart point the Expert Advisor or script has been dropped to.
  - **Method**: N/A (MQL5 function)
  - **Returns**: The price coordinate.

- **`ChartTimeOnDropped()`**
  - **Description**: Returns the time coordinate of the chart point the Expert Advisor or script has been dropped to.
  - **Method**: N/A (MQL5 function)
  - **Returns**: The time coordinate.

- **`ChartXOnDropped()`**
  - **Description**: Returns the X coordinate of the chart point the Expert Advisor or script has been dropped to.
  - **Method**: N/A (MQL5 function)
  - **Returns**: The X coordinate.

- **`ChartYOnDropped()`**
  - **Description**: Returns the Y coordinate of the chart point the Expert Advisor or script has been dropped to.
  - **Method**: N/A (MQL5 function)
  - **Returns**: The Y coordinate.

- **`ChartSetSymbolPeriod(chart_id, symbol, period)`**
  - **Description**: Changes the symbol and period of the specified chart.
  - **Method**: N/A (MQL5 function)
  - **Parameters**:
    - `chart_id` (long) - The ID of the chart to modify.
    - `symbol` (string) - The new symbol for the chart.
    - `period` (ENUM_TIMEFRAMES) - The new period for the chart.

- **`ChartScreenShot(chart_id, filename, size_x, size_y, format)`**
  - **Description**: Provides a screenshot of the chart in its current state in a specified format (GIF, PNG, or BMP).
  - **Method**: N/A (MQL5 function)
  - **Parameters**:
    - `chart_id` (long) - The ID of the chart to screenshot.
    - `filename` (string) - The name of the file to save the screenshot to.
    - `size_x` (int) - The width of the screenshot.
    - `size_y` (int) - The height of the screenshot.
    - `format` (int) - The image format (e.g., IMG_TYPE_PNG, IMG_TYPE_BMP, IMG_TYPE_GIF).
  - **Returns**: True if the screenshot was saved successfully, false otherwise.
```

--------------------------------

### Close Position with TRADE_ACTION_DEAL in MQL5

Source: https://www.mql5.com/en/docs/constants/tradingconstants/enum_trade_request_actions

This MQL5 code snippet demonstrates how to close an open position using the TRADE_ACTION_DEAL operation. It sets up a trade request with position details, determines the correct price and order type for closing (buy or sell), and then sends the request. Error handling for OrderSend is included.

```MQL5
request.action = TRADE_ACTION_DEAL; // type of trade operation  
request.position = position_ticket; // ticket of the position  
request.symbol = position_symbol; // symbol   
request.volume = volume; // volume of the position  
request.deviation = 5; // allowed deviation from the price  
request.magic = EXPERT_MAGIC; // MagicNumber of the position  
//--- set the price and order type depending on the position type  
if(type == POSITION_TYPE_BUY)  
{
  request.price = SymbolInfoDouble(position_symbol, SYMBOL_BID);  
  request.type = ORDER_TYPE_SELL;  
}
else  
{
  request.price = SymbolInfoDouble(position_symbol, SYMBOL_ASK);  
  request.type = ORDER_TYPE_BUY;  
}
//--- output information about the closure  
PrintFormat("Close #%I64d %s %s", position_ticket, position_symbol, EnumToString(type));  
//--- send the request  
if (!OrderSend(request, result))
  PrintFormat("OrderSend error %d", GetLastError()); // if unable to send the request, output the error code  
//--- information about the operation   
PrintFormat("retcode=%u deal=%I64u order=%I64u", result.retcode, result.deal, result.order);
```

--------------------------------

### Position Properties Access

Source: https://www.mql5.com/en/docs/constants/tradingconstants/positionproperties

This API describes how to retrieve various properties of a trading position using MQL5 functions. Properties are categorized into integer, double, and string types.

```APIDOC
## Position Properties API

### Description
This API allows developers to access various properties associated with a trading position. These properties provide details about the position's state, such as its ticket, open time, volume, price, and more. Different functions are used to retrieve properties based on their data type (integer, double, or string).

### Accessing Integer Properties
Use the `PositionGetInteger()` function to retrieve integer-based position properties.

#### Position Integer Properties
| Identifier          | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | Type | Function Call Example                     |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------|-------------------------------------------|
| `POSITION_TICKET`   | Position ticket. Unique number assigned to each newly opened position. It usually matches the ticket of an order used to open the position except when the ticket is changed as a result of service operations on the server, for example, when charging swaps with position re-opening. To find an order used to open a position, apply the `POSITION_IDENTIFIER` property. `POSITION_TICKET` value corresponds to `MqlTradeRequest::position`. | `long` | `PositionGetInteger(POSITION_TICKET)`     |
| `POSITION_TIME`     | Position open time                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | `datetime` | `PositionGetInteger(POSITION_TIME)`       |
| `POSITION_TIME_MSC` | Position opening time in milliseconds since 01.01.1970                                                                                                                                                                                                                                                                                                                                                                                                                         | `long` | `PositionGetInteger(POSITION_TIME_MSC)`   |
| `POSITION_TIME_UPDATE` | Position changing time                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | `datetime` | `PositionGetInteger(POSITION_TIME_UPDATE)`|
| `POSITION_TIME_UPDATE_MSC` | Position changing time in milliseconds since 01.01.1970                                                                                                                                                                                                                                                                                                                                                                                                                    | `long` | `PositionGetInteger(POSITION_TIME_UPDATE_MSC)` |
| `POSITION_TYPE`     | Position type                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | `ENUM_POSITION_TYPE` | `PositionGetInteger(POSITION_TYPE)`       |
| `POSITION_MAGIC`    | Position magic number (see ORDER_MAGIC)                                                                                                                                                                                                                                                                                                                                                                                                                                                  | `long` | `PositionGetInteger(POSITION_MAGIC)`      |
| `POSITION_IDENTIFIER` | Position identifier is a unique number assigned to each re-opened position. It does not change throughout its life cycle and corresponds to the ticket of an order used to open a position. Position identifier is specified in each order (`ORDER_POSITION_ID`) and deal (`DEAL_POSITION_ID`) used to open, modify, or close it. Use this property to search for orders and deals related to the position. When reversing a position in netting mode (using a single in/out trade), `POSITION_IDENTIFIER` does not change. However, `POSITION_TICKET` is replaced with the ticket of the order that led to the reversal. Position reversal is not provided in hedging mode. | `long` | `PositionGetInteger(POSITION_IDENTIFIER)` |
| `POSITION_REASON`   | The reason for opening a position                                                                                                                                                                                                                                                                                                                                                                                                                                                          | `ENUM_POSITION_REASON` | `PositionGetInteger(POSITION_REASON)`     |

### Accessing Double Properties
Use the `PositionGetDouble()` function to retrieve double-based position properties.

#### Position Double Properties
| Identifier           | Description                        |
|----------------------|------------------------------------|
| `POSITION_VOLUME`    | Position volume                    |
| `POSITION_PRICE_OPEN`| Position open price                |
| `POSITION_SL`        | Stop Loss level of opened position |
| `POSITION_TP`        | Take Profit level of opened position |
| `POSITION_PRICE_CURRENT` | Current price of the position symbol |
| `POSITION_SWAP`      | Cumulative swap                    |
| `POSITION_PROFIT`    | Current profit                     |

### Accessing String Properties
Use the `PositionGetString()` function to retrieve string-based position properties.

#### Position String Properties
| Identifier          | Description                                       |
|---------------------|---------------------------------------------------|
| `POSITION_SYMBOL`   | Symbol of the position                            |
| `POSITION_COMMENT`  | Position comment                                  |
| `POSITION_EXTERNAL_ID` | Position identifier in an external trading system (on the Exchange) |

### Position Type Enumeration
`ENUM_POSITION_TYPE` defines the direction of an open position.

| Identifier       | Description | Value |
|------------------|-------------|-------|
| `POSITION_TYPE_BUY`  | Buy         | 0     |
| `POSITION_TYPE_SELL` | Sell        | 1     |

### Position Reason Enumeration
`ENUM_POSITION_REASON` describes the cause for opening a position.

| Identifier                | Description                                                  |
|---------------------------|--------------------------------------------------------------|
| `POSITION_REASON_CLIENT`  | The position was opened as a result of activation of an order placed from a desktop terminal |
| `POSITION_REASON_MOBILE`  | The position was opened as a result of activation of an order placed from a mobile application |
| `POSITION_REASON_WEB`     | The position was opened as a result of activation of an order placed from the web platform |
| `POSITION_REASON_EXPERT`  | The position was opened as a result of activation of an order placed from an MQL5 program, i.e. an Expert Advisor or a script |

### Request Example
```json
{
  "action": "getPositionProperty",
  "propertyType": "integer",
  "propertyName": "POSITION_TICKET"
}
```

### Response Example
```json
{
  "success": true,
  "value": 123456789
}
```
```

--------------------------------

### MQL5 Structure with Default (No) Alignment

Source: https://www.mql5.com/en/docs/basis/types/classes

Demonstrates a simple MQL5 structure without explicit alignment. It shows that the structure size is the sum of its members' sizes when 'pack()' is used without arguments (defaulting to 1-byte alignment). This is useful for understanding basic structure memory layout.

```MQL5
//+------------------------------------------------------------------+
//| Script program start function |
//+------------------------------------------------------------------+
void OnStart()
{
//--- simple structure with no alignment
struct Simple_Structure
{
char c; // sizeof(char)=1
short s; // sizeof(short)=2
int i; // sizeof(int)=4
double d; // sizeof(double)=8
};

//--- declare a simple structure instance 
Simple_Structure s;

//--- display the size of each structure member
Print("sizeof(s.c)=",sizeof(s.c));
Print("sizeof(s.s)=",sizeof(s.s));
Print("sizeof(s.i)=",sizeof(s.i));
Print("sizeof(s.d)=",sizeof(s.d));

//--- make sure the size of POD structure is equal to the sum of its members' size
Print("sizeof(simple_structure)=",sizeof(simple_structure));
/*
Result:
sizeof(s.c)=1
sizeof(s.s)=2
sizeof(s.i)=4
sizeof(s.d)=8
sizeof(simple_structure)=15
*/
}
```

--------------------------------

### Define MQL5 Indicator Input Parameter Structure (MqlParam)

Source: https://www.mql5.com/en/docs/constants/structures/mqlparam

The MqlParam structure defines the type and value of an input parameter for a technical indicator. It includes fields for integer, double, and string types, selected based on the ENUM_DATATYPE. This is crucial for functions like IndicatorCreate().

```MQL5
struct MqlParam {
  ENUM_DATATYPE  type; // type of the input parameter, value of ENUM_DATATYPE
  long integer_value; // field to store an integer type
  double double_value; // field to store a double type
  string string_value; // field to store a string type
};
```

--------------------------------

### MQL5 Fill Matrix with Random Values Function

Source: https://www.mql5.com/en/docs/opencl/clbufferwrite

A utility function to fill a matrix with random floating-point values. It iterates through each element of the matrix and assigns a randomized value within a specific range.

```MQL5
//+------------------------------------------------------------------+
//| Fills the matrix with random values |
//+------------------------------------------------------------------+
void MatrixRandom(matrixf& m)
{
for(ulong r=0; r<m.Rows(); r++)
{
for(ulong c=0; c<m.Cols(); c++)
{
m[r][c]=(float)((MathRand()-16383.5)/32767.);
}
}
}
```

--------------------------------

### Initialize Chart Label Properties in MQL5

Source: https://www.mql5.com/en/docs/eventfunctions/eventchartcustom

Sets various properties for a chart label object, including its position, font, text content, font size, and selection state. This function is typically called during the initialization phase of an Expert Advisor or indicator.

```MQL5
ObjectSetInteger(0,labelID,OBJPROP_XDISTANCE,100);
ObjectSetInteger(0,labelID,OBJPROP_YDISTANCE,50);
ObjectSetString(0,labelID,OBJPROP_FONT,"Trebuchet MS");
ObjectSetString(0,labelID,OBJPROP_TEXT,"No information");
ObjectSetInteger(0,labelID,OBJPROP_FONTSIZE,20);
ObjectSetInteger(0,labelID,OBJPROP_SELECTABLE,0);
```

--------------------------------

### MQL5: Statistical Probability Function Declarations

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/hypergeometric

These are declarations for various statistical probability functions available in MQL5. They are used for complex statistical calculations but do not include implementation details. Specific use cases depend on the individual function's purpose, such as calculating moments or probability densities for different distributions.

```MQL5
MathMomentsGeometric
MathProbabilityDensityHypergeometric
```

--------------------------------

### Declare Bitmap Resource as 2D Array in MQL5

Source: https://www.mql5.com/en/docs/runtime/resources

Declares a resource variable to hold bitmap data from a BMP file as a two-dimensional array. The array is structured as [height][width].

```MQL5
#resource "image.bmp" as bitmap ExtBitmap2[][]
```

--------------------------------

### Normalize MQL5 Values by Range and Precision

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/exponential

This MQL5 code calculates the range between maximum and minimum values, determines the appropriate precision using base-10 logarithm, and then normalizes both the maximum and minimum values to that precision. It also calculates the step value for sequence generation, adjusting it if the range is too small.

```mql5
double range = MathAbs(maxv - minv);
int degree = (int)MathRound(MathLog10(range));
//--- normalize the maximum and minimum values to the specified precision
maxv = NormalizeDouble(maxv, degree);
minv = NormalizeDouble(minv, degree);
//--- sequence generation step is also set based on the specified precision
stepv = NormalizeDouble(MathPow(10, -degree), degree);
if ((maxv - minv) / stepv < 10)
  stepv /= 10.;
```

--------------------------------

### MQL5: Set OpenCL Kernel Argument Memory

Source: https://www.mql5.com/en/docs/opencl/clsetkernelargmem

The CLSetKernelArgMem function in MQL5 is used to set an OpenCL buffer as an argument for an OpenCL kernel. It takes the kernel handle, argument index, and the OpenCL buffer handle as input. It returns a boolean indicating success or failure.

```MQL5
bool CLSetKernelArgMem(
int kernel, // Handle to the kernel of an OpenCL program   
uint arg_index, // The number of the argument of the OpenCL function   
int cl_mem_handle // Handle to OpenCL buffer   
);
```

--------------------------------

### MQL5 Gamma Distribution Functions: Density, CDF, Quantile, Random, Moments

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/gamma

This snippet covers MQL5 functions for calculating the probability density (MathProbabilityDensityGamma), cumulative distribution (MathCumulativeDistributionGamma), quantiles (MathQuantileGamma), generating random numbers (MathRandomGamma), and calculating moments (MathMomentsGamma) for the gamma distribution. These functions are essential for statistical analysis and simulations involving the gamma distribution.

```MQL5
#include <Math\Stat\Gamma.mqh>
#include <Math\Stat\Math.mqh>

// Function to calculate probability density
// double MathProbabilityDensityGamma(const double &x[], double a, double b, bool log_form, double &result[]);

// Function to calculate cumulative distribution
// double MathCumulativeDistributionGamma(const double &x[], double a, double b, bool log_form, double &result[]);

// Function to calculate quantiles
// double MathQuantileGamma(const double &p[], double a, double b, double &result[]);

// Function to generate pseudorandom numbers
// void MathRandomGamma(double a, double b, int n, double &data[]);

// Function to calculate moments
// void MathMomentsGamma(double a, double b, int num_moments, double &moments[]);

```

--------------------------------

### Select Symbol in MarketWatch using Python

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5symbolselect_py

This snippet demonstrates how to use the symbol_select function from the MetaTrader5 library to select a financial instrument (e.g., EURCAD) in the MarketWatch window. It includes initialization, error handling for connection and symbol selection, and retrieving symbol information.

```python
import MetaTrader5 as mt5
import pandas as pd

# display data on the MetaTrader 5 package
print("MetaTrader5 package author: ",mt5.__author__)
print("MetaTrader5 package version: ",mt5.__version__)
print()

# establish connection to the MetaTrader 5 terminal
if not mt5.initialize(login=25115284, server="MetaQuotes-Demo",password="4zatlbqx"):
    print("initialize() failed, error code =",mt5.last_error())
    quit()

# attempt to enable the display of the EURCAD in MarketWatch
selected=mt5.symbol_select("EURCAD",True)
if not selected:
    print("Failed to select EURCAD, error code =",mt5.last_error())
else:
    symbol_info=mt5.symbol_info("EURCAD")
    print(symbol_info)
    print("EURCAD: currency_base =",symbol_info.currency_base," currency_profit =",symbol_info.currency_profit," currency_margin =",symbol_info.currency_margin)
    print()

    # get symbol properties in the form of a dictionary
    print("Show symbol_info()._asdict():")
    symbol_info_dict = symbol_info._asdict()
    for prop in symbol_info_dict:
        print(" {}={}".format(prop, symbol_info_dict[prop]))
    print()

    # convert the dictionary into DataFrame and print
    df=pd.DataFrame(list(symbol_info_dict.items()),columns=['property','value'])
    print("symbol_info_dict() as dataframe:")
    print(df)

```

--------------------------------

### DXContextGetColors

Source: https://www.mql5.com/en/docs/directx/dxcontextgetcolors

Retrieves an image from a specified graphic context with control over size, offset, and array.

```APIDOC
## DXContextGetColors

### Description
Gets an image of a specified size and offset from a graphic context.

### Method
*This is a function call, not a typical HTTP method.*

### Endpoint
*N/A - This is a library function.*

### Parameters
#### Path Parameters
*None*

#### Query Parameters
*None*

#### Request Body
*None*

### Request Example
```mql5
// Example usage (conceptual):
int context_handle = DXContextCreate();
uint image_data[];
bool success = DXContextGetColors(context_handle, image_data, 512, 512, 10, 20);
```

### Response
#### Success Response (true)
- **bool** - Returns true if the image was successfully retrieved.

#### Response Example
```json
{
  "success": true
}
```

#### Error Response (false)
- **bool** - Returns false if the operation failed. Call GetLastError() for error details.
```

--------------------------------

### Draw Primitives with DirectX

Source: https://www.mql5.com/en/docs/directx/dxcontextcreate

Draws a specified number of primitives using the currently bound shader and vertex buffer. The type of primitives is determined by the current primitive topology. Requires a valid context handle.

```MQL5
void DXDraw(
  int context_handle, // handle of the graphic context
  uint vertex_count,  // number of vertices to draw
  uint start_vertex   // index of the first vertex to draw
);

```

--------------------------------

### MQL5: Check for Allowed File Operations During Optimization

Source: https://www.mql5.com/en/docs/optimization_frames

This MQL5 code snippet checks if file operations are permitted during optimization or forward testing. It's crucial for MQL5 Cloud Network optimizations where disk writes are restricted to 4GB. If file operations are not allowed, the code within the 'if' block will not execute, preventing potential errors or exceeding network limits.

```MQL5
int handle = INVALID_HANDLE;
bool file_operations_allowed = true;
if (MQLInfoInteger(MQL_OPTIMIZATION) || MQLInfoInteger(MQL_FORWARD))
  file_operations_allowed = false;

if (file_operations_allowed)
{
  // ... file operations like FileOpen() can be performed here
  handle = FileOpen("my_data.log", FILE_WRITE | FILE_CSV);
  // ... other file operations
}
```

--------------------------------

### Retrieve Order Information using orders_get

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5ordersget_py

This function retrieves all open orders matching a specified group. It's useful for monitoring trading activities and filtering orders based on criteria like symbols. The primary input is the 'group' parameter. The output is a list of TradeOrder objects or a count if 'group' is specified as a string pattern. Ensure the MetaTrader5 package is initialized before calling this function.

```python
import MetaTrader5 as mt5

# Initialize MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed, error code =", mt5.last_error())
    quit()

# Get all orders for GBPUSD
total_orders_gbpusd = mt5.orders_get(group="*GBP*")
print(f"Total orders on GBPUSD: {total_orders_gbpusd}")

# Example of retrieving detailed order information (output format shown in text)
# orders_get(group="*GBP*") would return detailed order information if not just counting

# shutdown connection to MetaTrader 5 terminal
mt5.shutdown()
```

--------------------------------

### Calculate Binomial Probability Density Function (MQL5)

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/binomial

Calculates the probability density function of the binomial distribution. This function can be used for individual values or arrays of values. It requires the input value(s), number of tests (n), and probability of success (p).

```MQL5
#include <Math\Stat\Binomial.mqh>

// Example usage:
double x_values[] = {0, 1, 2, 3, 4};
double n_par = 5;
double p_par = 0.5;
double density_values[];

MathProbabilityDensityBinomial(x_values, n_par, p_par, false, density_values);
// density_values will contain the probability densities for each x_value
```

--------------------------------

### Set Vertex Shader Layout in MQL5

Source: https://www.mql5.com/en/docs/directx/dxshadersetlayout

The DXShaderSetLayout function configures the vertex attribute layout for a given shader. It requires a shader handle and an array describing each vertex element's semantic name, index, and data format. The layout must match the vertex buffer and shader input signature.

```MQL5
bool DXShaderSetLayout(
   int shader, // shader handle   
   const DXVertexLayout& layout[] // vertex layout description
);

struct DXVertexLayout {
   string semantic_name;     // HLSL semantic name
   uint semantic_index;      // Semantic index
   ENUM_DX_FORMAT format;    // Data format
};
```

--------------------------------

### Helper Function to Calculate Histogram Array (MQL5)

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/beta

A utility function to calculate histogram data from a sample dataset. It determines the intervals, frequencies within each interval, and the minimum and maximum values of the data. This function is used in conjunction with statistical distribution functions to visualize data.

```MQL5
bool CalculateHistogramArray(const double &data[],double &intervals[],double &frequency[],
                             double &maxv,double &minv,const int cells=10)
{
   if(cells<=1) return (false);
   int size=ArraySize(data);
   if(size<cells*10) return (false);
   minv=data[ArrayMinimum(data)];
   maxv=data[ArrayMaximum(data)];
   double range=maxv-minv;
   double width=range/cells;
   if(width==0) return false;
   ArrayResize(intervals,cells);
   ArrayResize(frequency,cells);
   //--- define the interval centers
   for(int i=0; i<cells; i++)
   {
      intervals[i]=minv+(i+0.5)*width;
      frequency[i]=0;
   }
   //--- fill the frequencies of falling within the interval
   for(int i=0; i<size; i++)
   {
      int ind=int((data[i]-minv)/width);
      if(ind>=cells) ind=cells-1;
      frequency[ind]++;
   }
   return (true);
}
```

--------------------------------

### DXBufferCreate

Source: https://www.mql5.com/en/docs/directx/dxbuffercreate

Creates a buffer of a specified type based on a data array. This function is essential for preparing data (like vertices or indices) for rendering in DirectX.

```APIDOC
## DXBufferCreate

### Description
Creates a buffer of a specified type based on a data array.

### Method
`int DXBufferCreate(int context, ENUM_DX_BUFFER_TYPE buffer_type, const void& data[], uint start=0, uint count=WHOLE_ARRAY);`

### Endpoint
N/A (This is a function call within MQL5)

### Parameters
#### Path Parameters
None

#### Query Parameters
None

#### Request Body
**context** (int) - Required - Handle for a graphic context created in DXContextCreate().
**buffer_type** (ENUM_DX_BUFFER_TYPE) - Required - Buffer type from the ENUM_DX_BUFFER_TYPE enumeration.
**data[]** (const void&) - Required - Data for creating a buffer.
**start** (uint) - Optional - Index of the first element of the array, starting from which the array values are used to create a buffer. By default, the data is taken from the beginning of the array.
**count** (uint) - Optional - Number of values. By default, the entire array is used (count=WHOLE_ARRAY).

### Request Example
```
// Example usage (conceptual)
int context_handle = DXContextCreate();
float vertices[] = { ... }; // Array of vertex data
int buffer_handle = DXBufferCreate(context_handle, DX_BUFFER_VERTEX, vertices);
```

### Response
#### Success Response (200)
**Return Value** (int) - The handle for a created buffer.

#### Response Example
```
// Conceptual success response
int buffer_handle = 12345; // Example handle
```

### Error Handling
- Returns INVALID_HANDLE in case of an error.
- Call `GetLastError()` to retrieve the error code.

### Notes
- For index buffers, the `data[]` array must be of type `uint`.
- For vertex buffers, `data[]` receives an array of structures describing vertices.
- Buffers created with `DXBufferCreate` must be explicitly released using `DXRelease()` when no longer needed.
```

--------------------------------

### Calculate Order Profit with Python MetaTrader5

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5ordercalcprofit_py

Demonstrates how to calculate profit for BUY and SELL orders using the `order_calc_profit` function from the MetaTrader5 Python package. It connects to the terminal, retrieves account currency, iterates through symbols, and calculates profit based on specified lot size and price movements.

```python
import MetaTrader5 as mt5

# display data on the MetaTrader 5 package
print("MetaTrader5 package author: ",mt5.__author__)
print("MetaTrader5 package version: ",mt5.__version__)

# establish connection to MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed, error code =",mt5.last_error())
    quit()

# get account currency
account_currency=mt5.account_info().currency
print("Account currency:",account_currency)

# arrange the symbol list
symbols = ("EURUSD","GBPUSD","USDJPY")
print("Symbols to check margin:", symbols)
# estimate profit for buying and selling
lot=1.0
distance=300
for symbol in symbols:
    symbol_info=mt5.symbol_info(symbol)
    if symbol_info is None:
        print(symbol,"not found, skipped")
        continue
    if not symbol_info.visible:
        print(symbol, "is not visible, trying to switch on")
        if not mt5.symbol_select(symbol,True):
            print("symbol_select({}}) failed, skipped",symbol)
            continue
    point=mt5.symbol_info(symbol).point
    symbol_tick=mt5.symbol_info_tick(symbol)
    ask=symbol_tick.ask
    bid=symbol_tick.bid
    buy_profit=mt5.order_calc_profit(mt5.ORDER_TYPE_BUY,symbol,lot,ask,ask+distance*point) 
    if buy_profit!=None:
        print(" buy {} {} lot: profit on {} points => {} {}".format(symbol,lot,distance,buy_profit,account_currency));
    else:
        print("order_calc_profit(ORDER_TYPE_BUY) failed, error code =",mt5.last_error())
    sell_profit=mt5.order_calc_profit(mt5.ORDER_TYPE_SELL,symbol,lot,bid,bid-distance*point) 
    if sell_profit!=None:
        print(" sell {} {} lots: profit on {} points => {} {}".format(symbol,lot,distance,sell_profit,account_currency));
    else:
        print("order_calc_profit(ORDER_TYPE_SELL) failed, error code =",mt5.last_error())
    print()

# shut down connection to the MetaTrader 5 terminal
mt5.shutdown()
```

--------------------------------

### Set Shader Textures in MQL5 using DXShaderTexturesSet

Source: https://www.mql5.com/en/docs/directx/dxshadertexturesset

The DXShaderTexturesSet function in MQL5 is used to bind an array of texture handles to a specific shader. The number of textures provided must match the number of Texture2D objects declared in the shader code. Successful execution returns true, while failures return false, and GetLastError() can provide detailed error information.

```mql5
bool DXShaderTexturesSet(
int shader, // shader handle   
const int& textures[] // array of structure handles   
);
```

--------------------------------

### MQL5 OnTimer Event Function

Source: https://www.mql5.com/en/docs/basis/function/events

The OnTimer() function is executed when a Timer event occurs, generated by the system timer. It is applicable to Expert Advisors and indicators, but not scripts. The frequency is controlled by EventSetTimer() and EventKillTimer().

```MQL5
void OnTimer();
```

--------------------------------

### Fetch and Process Economic Calendar Data in MQL5

Source: https://www.mql5.com/en/docs/constants/structures/mqlcalendar

This MQL5 script retrieves historical economic calendar event data for a specified country code. It demonstrates how to use the `CalendarValueHistory` function, handle potential retrieval errors, and process the returned data. The script also shows how to resize the data array and print it to the journal.

```mql5
ulong id; // value ID
ulong event_id; // event ID
datetime time; // event date and time
datetime period; // event reporting period
int revision; // revision of the published indicator relative to the reporting period
double actual_value; // actual value
double prev_value; // previous value
double revised_prev_value; // revised previous value
double forecast_value; // forecast value
ENUM_CALENDAR_EVENT_IMPACT impact_type; // potential impact on the currency rate
};

//+------------------------------------------------------------------+
//| Script program start function |
//+------------------------------------------------------------------+
void OnStart()
{
//---
//--- country code for EU (ISO 3166-1 Alpha-2)
string EU_code="EU";
//--- get all EU event values
MqlCalendarValue values[];
//--- set the boundaries of the interval we take the events from
datetime date_from=D'01.01.2021'; // take all events from 2021
datetime date_to=0; // 0 means all known events, including the ones that have not occurred yet
//--- request EU event history since 2021
if(!CalendarValueHistory(values, date_from, date_to, EU_code))
{
PrintFormat("Error! Failed to get events for country_code=%s", EU_code);
PrintFormat("Error code: %d", GetLastError());
return;
}
else
PrintFormat("Received event values for country_code=%s: %d",
EU_code, ArraySize(values));
//--- reduce the size of the array for output to the Journal
if(ArraySize(values)>5)
ArrayResize(values, 5);
//--- output event values to the Journal as they are, without checking or converting to actual values
Print("Output calendar values as they are");
ArrayPrint(values);

//--- check the field values and convert to actual values
//--- option 1 to check and get the values
AdjustedCalendarValue values_adjusted_1[];
int total=ArraySize(values);
ArrayResize(values_adjusted_1, total);
//--- copy the values with checks and adjustments
for(int i=0; i<total; i++)
{
values_adjusted_1[i].id=values[i].id;
values_adjusted_1[i].event_id=values[i].event_id;
values_adjusted_1[i].time=values[i].time;
values_adjusted_1[i].period=values[i].period;
values_adjusted_1[i].revision=values[i].revision;
values_adjusted_1[i].impact_type=values[i].impact_type;
//--- check values and divide by 1,000,000
if(values[i].actual_value==LONG_MIN)
values_adjusted_1[i].actual_value=double("nan");
else
values_adjusted_1[i].actual_value=values[i].actual_value/1000000.;

if(values[i].prev_value==LONG_MIN)
values_adjusted_1[i].prev_value=double("nan");
else
values_adjusted_1[i].prev_value=values[i].prev_value/1000000.;

if(values[i].revised_prev_value==LONG_MIN)
values_adjusted_1[i].revised_prev_value=double("nan");
else
values_adjusted_1[i].revised_prev_value=values[i].revised_prev_value/1000000.;

if(values[i].forecast_value==LONG_MIN)
values_adjusted_1[i].forecast_value=double("nan");
else
values_adjusted_1[i].forecast_value=values[i].forecast_value/1000000.;
}
Print("The first method to check and get calendar values");
ArrayPrint(values_adjusted_1);

//--- option 2 to check and get the values
AdjustedCalendarValue values_adjusted_2[];
ArrayResize(values_adjusted_2, total);
//--- copy the values with checks and adjustments
for(int i=0; i<total; i++)
{
values_adjusted_2[i].id=values[i].id;
values_adjusted_2[i].event_id=values[i].event_id;
values_adjusted_2[i].time=values[i].time;
values_adjusted_2[i].period=values[i].period;
values_adjusted_2[i].revision=values[i].revision;
values_adjusted_2[i].impact_type=values[i].impact_type;
//--- check and get values
if(values[i].HasActualValue())
values_adjusted_2[i].actual_value=values[i].GetActualValue();
else
values_adjusted_2[i].actual_value=double("nan");

if(values[i].HasPreviousValue())
values_adjusted_2[i].prev_value=values[i].GetPreviousValue();
else
values_adjusted_2[i].prev_value=double("nan");

if(values[i].HasRevisedValue())
values_adjusted_2[i].revised_prev_value=values[i].GetRevisedValue();
else
values_adjusted_2[i].revised_prev_value=double("nan");

if(values[i].HasForecastValue())
values_adjusted_2[i].forecast_value=values[i].GetForecastValue();
else
values_adjusted_2[i].forecast_value=double("nan");
}
Print("The second method to check and get calendar values");
ArrayPrint(values_adjusted_2);

//--- option 3 to get the values - without checks
AdjustedCalendarValue values_adjusted_3[];
ArrayResize(values_adjusted_3, total);
//--- copy the values with checks and adjustments
for(int i=0; i<total; i++)
{
values_adjusted_3[i].id=values[i].id;
values_adjusted_3[i].event_id=values[i].event_id;
values_adjusted_3[i].time=values[i].time;
values_adjusted_3[i].period=values[i].period;

```

--------------------------------

### MQL5: Calculate Max, Min, and Step Values

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/gamma

Calculates normalized maximum, minimum, and step values for a given range. It determines the precision based on the range's magnitude and adjusts the step value accordingly.

```MQL5
//+------------------------------------------------------------------+
void GetMaxMinStepValues(double &maxv,double &minv,double &stepv)
{
//--- calculate the absolute range of the sequence to obtain the precision of normalization
double range=MathAbs(maxv-minv);
int degree=(int)MathRound(MathLog10(range));
//--- normalize the maximum and minimum values to the specified precision
maxv=NormalizeDouble(maxv,degree);
minv=NormalizeDouble(minv,degree);
//--- sequence generation step is also set based on the specified precision
stepv=NormalizeDouble(MathPow(10,-degree),degree);
if((maxv-minv)/stepv<10)
stepv/=10.;
}
```

--------------------------------

### MQL5 Volume Filling Policies

Source: https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties

Defines the volume filling policies for trade orders. These policies dictate how an order's volume should be matched with available market liquidity.

```MQL5
enum ENUM_ORDER_TYPE_FILLING
{
   ORDER_FILLING_FOK,
   ORDER_FILLING_IOC,
   ORDER_FILLING_BOC,
   ORDER_FILLING_RETURN
};
```

--------------------------------

### MQL5 MqlTradeResult Structure Definition

Source: https://www.mql5.com/en/docs/constants/structures/mqltraderesult

Defines the MqlTradeResult structure used to receive results from trade server operations in MQL5. This structure contains fields for return codes, deal and order identifiers, confirmed volume and price, current market prices, and broker comments.

```MQL5
struct MqlTradeResult {
  uint  retcode; // Operation return code
  ulong deal; // Deal ticket, if it is performed
  ulong order; // Order ticket, if it is placed
  double volume; // Deal volume, confirmed by broker
  double price; // Deal price, confirmed by broker
  double bid; // Current Bid price
  double ask; // Current Ask price
  string comment; // Broker comment to operation (by default it is filled by description of trade server return code)
  uint  request_id; // Request ID set by the terminal during the dispatch
  int  retcode_external; // Return code of an external trading system
};

```

--------------------------------

### MQL5 OnTesterPass: Dynamic Optimization Result Handling

Source: https://www.mql5.com/en/docs/basis/function/events

The OnTesterPass() function handles the TesterPass event, which is generated when a frame is received during EA optimization. It allows for dynamic, on-the-spot processing of optimization results without waiting for the entire process to complete.

```MQL5
void OnTesterPass()
{
  // Logic to handle optimization results dynamically per pass
}
```

--------------------------------

### Generate F-distribution Sample and Plot Histogram (MQL5)

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/fisher

Generates a sample of pseudo-random numbers from the F-distribution using MathRandomF and visualizes it as a histogram. It then overlays the theoretical F-distribution curve for comparison. Requires Math.mqh, F.mqh, and Graphic.mqh libraries.

```MQL5
#include <Graphics\Graphic.mqh>
#include <Math\Stat\F.mqh>
#include <Math\Stat\Math.mqh>

#property script_show_inputs

//--- input parameters
input double nu_1=100; // the first number of degrees of freedom
input double nu_2=100; // the second number of degrees of freedom

//+------------------------------------------------------------------+
//| Script program start function |
//+------------------------------------------------------------------+
void OnStart()
{
//--- hide the price chart
ChartSetInteger(0,CHART_SHOW,false);

//--- initialize the random number generator 
MathSrand(GetTickCount());

//--- generate a sample of the random variable
long chart=0;
string name="GraphicNormal";
int n=1000000; // the number of values in the sample
int ncells=51; // the number of intervals in the histogram
double x[]; // centers of the histogram intervals
double y[]; // the number of values from the sample falling within the interval
double data[]; // sample of random values
double max,min; // the maximum and minimum values in the sample

//--- obtain a sample from the Fisher's F-distribution
MathRandomF(nu_1,nu_2,n,data);

//--- calculate the data to plot the histogram
CalculateHistogramArray(data,x,y,max,min,ncells);

//--- obtain the sequence boundaries and the step for plotting the theoretical curve
double step;
GetMaxMinStepValues(max,min,step);
step=MathMin(step,(max-min)/ncells);

//--- obtain the theoretically calculated data at the interval of [min,max]
double x2[];
double y2[];
MathSequence(min,max,step,x2);
MathProbabilityDensityF(x2,nu_1,nu_2,false,y2);

//--- set the scale
double theor_max=y2[ArrayMaximum(y2)];
double sample_max=y[ArrayMaximum(y)];
double k=sample_max/theor_max;
for(int i=0; i<ncells; i++)
 y[i]/=k;

//--- output charts
CGraphic graphic;
if(ObjectFind(chart,name)<0)
 graphic.Create(chart,name,0,0,0,780,380);
else
 graphic.Attach(chart,name);
graphic.BackgroundMain(StringFormat("F-distribution nu1=%G nu2=%G",nu_1,nu_2));
graphic.BackgroundMainSize(16);

//--- plot all curves
graphic.CurveAdd(x,y,CURVE_HISTOGRAM,"Sample").HistogramWidth(4);

//--- and now plot the theoretical curve of the distribution density
graphic.CurveAdd(x2,y2,CURVE_LINES,"Theory");
graphic.CurvePlotAll();

//--- plot all curves
graphic.Update();
}
//+------------------------------------------------------------------+
//| Calculate frequencies for data set |
//+------------------------------------------------------------------+
bool CalculateHistogramArray(const double &data[],double &intervals[],double &frequency[],
double &maxv,double &minv,const int cells=10)
{
if(cells<=1) return (false);
int size=ArraySize(data);
if(size<cells*10) return (false);
minv=data[ArrayMinimum(data)];
maxv=data[ArrayMaximum(data)];
double range=maxv-minv;
double width=range/cells;
if(width==0) return false;
ArrayResize(intervals,cells);
ArrayResize(frequency,cells);

//--- define the interval centers
for(int i=0; i<cells; i++)
{
intervals[i]=minv+(i+0.5)*width;
frequency[i]=0;
}

//--- fill the frequencies of falling within the interval
for(int i=0; i<size; i++)
{
int ind=int((data[i]-minv)/width);
if(ind>=cells) ind=cells-1;
frequency[ind]++;
}
return (true);
}
//+------------------------------------------------------------------+
//| Calculates values for sequence generation |
//+------------------------------------------------------------------+
void GetMaxMinStepValues(double &maxv,double &minv,double &stepv)
{

```

--------------------------------

### Generate Cauchy Distribution Sample and Plot Histogram (MQL5)

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/cauchy

This MQL5 script generates a sample of random numbers from a Cauchy distribution, calculates histogram data, and plots both the sample histogram and the theoretical probability density curve. It utilizes functions like MathRandomCauchy, CalculateHistogramArray, MathProbabilityDensityCauchy, and the CGraphic class for visualization. Input parameters include the mean (a_par) and scale (b_par) of the distribution.

```MQL5
#include <Graphics\Graphic.mqh>
#include <Math\Stat\Cauchy.mqh>
#include <Math\Stat\Math.mqh>

#property script_show_inputs

//--- input parameters
input double a_par=-2; // mean parameter of the distribution
input double b_par=1; // scale parameter of the distribution

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   //--- hide the price chart
   ChartSetInteger(0,CHART_SHOW,false);

   //--- initialize the random number generator
   MathSrand(GetTickCount());

   //--- generate a sample of the random variable
   long chart=0;
   string name="GraphicNormal";
   int n=1000000; // the number of values in the sample
   int ncells=51; // the number of intervals in the histogram
   double x[]; // centers of the histogram intervals
   double y[]; // the number of values from the sample falling within the interval
   double data[]; // sample of random values
   double max,min; // the maximum and minimum values in the sample

   //--- obtain a sample from the Cauchy distribution
   MathRandomCauchy(a_par,b_par,n,data);

   //--- calculate the data to plot the histogram
   CalculateHistogramArray(data,x,y,max,min,ncells);

   //--- obtain the sequence boundaries and the step for plotting the theoretical curve
   double step;
   GetMaxMinStepValues(max,min,step);
   step=MathMin(step,(max-min)/ncells);

   //--- obtain the theoretically calculated data at the interval of [min,max]
   double x2[];
   double y2[];
   MathSequence(min,max,step,x2);
   MathProbabilityDensityCauchy(x2,a_par,b_par,false,y2);

   //--- set the scale
   double theor_max=y2[ArrayMaximum(y2)];
   double sample_max=y[ArrayMaximum(y)];
   double k=sample_max/theor_max;
   for(int i=0; i<ncells; i++)
      y[i]/=k;

   //--- output charts
   CGraphic graphic;
   if(ObjectFind(chart,name)<0)
      graphic.Create(chart,name,0,0,0,780,380);
   else
      graphic.Attach(chart,name);

   graphic.BackgroundMain(StringFormat("Cauchy distribution a=%G b=%G",a_par,b_par));
   graphic.BackgroundMainSize(16);

   //--- plot all curves
   graphic.CurveAdd(x,y,CURVE_HISTOGRAM,"Sample").HistogramWidth(6);

   //--- and now plot the theoretical curve of the distribution density
   graphic.CurveAdd(x2,y2,CURVE_LINES,"Theory");
   graphic.CurvePlotAll();

   //--- plot all curves
   graphic.Update();
}

//+------------------------------------------------------------------+
//| Calculate frequencies for data set                               |
//+------------------------------------------------------------------+
bool CalculateHistogramArray(const double &data[],double &intervals[],double &frequency[],
                            double &maxv,double &minv,const int cells=10)
{
   if(cells<=1)
      return(false);

   int size=ArraySize(data);
   if(size<cells*10)
      return(false);

   minv=data[ArrayMinimum(data)];
   maxv=data[ArrayMaximum(data)];
   Print("min=",minv," max=",maxv);

   minv=-20;
   maxv=20;

   double range=maxv-minv;
   double width=range/cells;
   if(width==0)
      return(false);

   ArrayResize(intervals,cells);
   ArrayResize(frequency,cells);

   //--- define the interval centers
   for(int i=0; i<cells; i++)
   {
      intervals[i]=minv+i*width;
      frequency[i]=0;
   }

   //--- fill the frequencies of falling within the interval
   for(int i=0; i<size; i++)
   {
      int ind=(int)MathRound((data[i]-minv)/width);
      if(ind>=0 && ind<cells)
         frequency[ind]++;
   }
   return(true);
}

//+------------------------------------------------------------------+
//| Calculates values for sequence generation                        |
//+------------------------------------------------------------------+
void GetMaxMinStepValues(double &maxv,double &minv,double &stepv)
{
   // Placeholder for actual implementation
}
```

--------------------------------

### Set DirectX Shader Textures

Source: https://www.mql5.com/en/docs/directx/dxcontextcreate

Binds textures to the shader's texture sampler slots. This allows the shader to access texture data for sampling. Requires a valid context handle.

```MQL5
void DXShaderTexturesSet(
  int context_handle, // handle of the graphic context
  int shader_handle,  // handle of the shader
  int texture_slot,   // shader texture slot index
  int texture_handle  // handle of the texture to bind
);

```

--------------------------------

### MQL5 Union for Long Integer and Double Value Interpretation

Source: https://www.mql5.com/en/docs/basis/types/classes

Demonstrates a union in MQL5 that allows a single memory location to hold either a long integer or a double value. This enables interpreting the same bit sequence as different data types, useful for low-level data manipulation and type casting. It shows how to assign values to members and print them in both integer and double formats.

```MQL5
union LongDouble   
{
long long_value;
double double_value;
};

void OnStart()
{
LongDouble lb;
lb.double_value=MathArcsin(2.0);
printf("1. double=%f integer=%I64X",lb.double_value,lb.long_value);
lb.long_value=0x7FEFFFFFFFFFFFFF;
printf("2. double=%.16e integer=%I64X",lb.double_value,lb.long_value);
lb.long_value=0x0010000000000000;
printf("3. double=%.16e integer=%.16I64X",lb.double_value,lb.long_value);
}
```

--------------------------------

### MQL5 Structure Declaration Syntax

Source: https://www.mql5.com/en/docs/basis/types/classes

Defines the basic syntax for declaring a structure in MQL5. Structures group related data of various types. The structure name itself cannot be used as a variable or function identifier.

```MQL5
struct structure_name {
  elements_description
};
```

--------------------------------

### CLExecutionStatus Function

Source: https://www.mql5.com/en/docs/opencl/clexecutionstatus

Retrieves the current execution status of an OpenCL kernel.

```APIDOC
## CLExecutionStatus

### Description
Returns the OpenCL program execution status.

### Method
`int` (Function Return Type)

### Endpoint
N/A (This is a function, not an API endpoint)

### Parameters
#### Path Parameters
None

#### Query Parameters
None

#### Request Body
None

### Request Example
```mql5
int kernel_handle = CLKernelCreate(...); // Assuming kernel_handle is obtained previously
int status = CLExecutionStatus(kernel_handle);
```

### Response
#### Success Response (Return Value)
- **status** (int) - The OpenCL program status. Possible values:
  - `CL_COMPLETE` (0): Program complete.
  - `CL_RUNNING` (1): Program is currently running.
  - `CL_SUBMITTED` (2): Program has been submitted for execution.
  - `CL_QUEUED` (3): Program is queued for execution.

#### Error Response
- **status** (int) - `-1` (minus one): An error occurred while executing `CLExecutionStatus()`.

#### Response Example
```json
{
  "status": 0 
}
```

```json
{
  "status": 1
}
```

```json
{
  "status": -1
}
```
```

--------------------------------

### MQL5: Normalize Sequence Range and Precision

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/fisher

This MQL5 code calculates the absolute range of a sequence (maxv - minv), determines the necessary precision (degree) using the base-10 logarithm, and normalizes the maximum and minimum values to this precision. It also sets the sequence generation step (stepv) based on the calculated precision, with an adjustment if the normalized range divided by the step is less than 10.

```MQL5
//--- calculate the absolute range of the sequence to obtain the precision of normalization
double range=MathAbs(maxv-minv);
int degree=(int)MathRound(MathLog10(range));
//--- normalize the maximum and minimum values to the specified precision
maxv=NormalizeDouble(maxv,degree);
minv=NormalizeDouble(minv,degree);
//--- sequence generation step is also set based on the specified precision
stepv=NormalizeDouble(MathPow(10,-degree),degree);
if((maxv-minv)/stepv<10)
stepv/=10.;
}
```

--------------------------------

### Copy Indicator Buffer Data in MQL5

Source: https://www.mql5.com/en/docs/indicators/ibands

This MQL5 code snippet demonstrates how to copy data from specific buffers of an indicator using the CopyBuffer function. It includes error handling to report failures and returns a boolean indicating success or failure. Requires a valid indicator handle and buffer indices.

```MQL5
//--- fill a part of the UpperBuffer array with values from the indicator buffer that has index 1
if(CopyBuffer(ind_handle,1,-shift,amount,upper_values)<0)
{
//--- if the copying fails, tell the error code
PrintFormat("Failed to copy data from the iBands indicator, error code %d",GetLastError());
//--- quit with zero result - it means that the indicator is considered as not calculated
return(false);
}

//--- fill a part of the LowerBuffer array with values from the indicator buffer that has index 2
if(CopyBuffer(ind_handle,2,-shift,amount,lower_values)<0)
{
//--- if the copying fails, tell the error code
PrintFormat("Failed to copy data from the iBands indicator, error code %d",GetLastError());
//--- quit with zero result - it means that the indicator is considered as not calculated
return(false);
}
//--- everything is fine
return(true);
}
```

--------------------------------

### MQL5 Offsetof Member Offset Calculation

Source: https://www.mql5.com/en/docs/basis/types/classes

Shows how to use the 'offsetof' function in MQL5 to determine the byte offset of a structure member from the beginning of the structure. This is crucial for low-level memory manipulation and understanding data layout, especially when interacting with external data formats.

```MQL5
//--- declare the Children type variable 
Children child;

//--- detect offsets from the beginning of the structure   
Print("offsetof(Children,c)=",offsetof(Children,c));
Print("offsetof(Children,s)=",offsetof(Children,s));
```

--------------------------------

### MQL5 Geometric Distribution Functions

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/geometric

This MQL5 code snippet includes functions for calculating various aspects of the geometric distribution. It covers probability density, cumulative distribution, quantiles, random number generation, and theoretical moments. These functions are essential for statistical analysis and simulations involving a geometric distribution.

```MQL5
#include <Graphics\Graphic.mqh>
#include <Math\Stat\Geometric.mqh>
#include <Math\Stat\Math.mqh>

#property script_show_inputs

//--- input parameters
input double p_par=0.2; // probability of event occurrence in one test

//+------------------------------------------------------------------+
//| Script program start function |
//+------------------------------------------------------------------+
void OnStart()
{
//--- hide the price chart
ChartSetInteger(0,CHART_SHOW,false);
//--- initialize the random number generator
MathSrand(GetTickCount());
//--- generate a sample of the random variable
long chart=0;
string name="GraphicNormal";
int n=1000000; // the number of values in the sample
int ncells=47; // the number of intervals in the histogram
double x[]; // centers of the histogram intervals
double y[]; // the number of values from the sample falling within the interval
double data[]; // sample of random values
double max,min; // the maximum and minimum values in the sample
//--- obtain a sample from the geometric distribution
MathRandomGeometric(p_par,n,data);
//--- calculate the data to plot the histogram
CalculateHistogramArray(data,x,y,max,min,ncells);
//--- obtain the sequence boundaries and the step for plotting the theoretical curve
double step;
GetMaxMinStepValues(max,min,step);
PrintFormat("max=%G min=%G",max,min);
//--- obtain the theoretically calculated data at the interval of [min,max]
double x2[];
double y2[];
MathSequence(0,ncells,1,x2);
MathProbabilityDensityGeometric(x2,p_par,false,y2);
//--- set the scale
double theor_max=y2[ArrayMaximum(y2)];
double sample_max=y[ArrayMaximum(y)];
double k=sample_max/theor_max;
for(int i=0; i<ncells; i++)
y[i]/=k;
//--- output charts
CGraphic graphic;
if(ObjectFind(chart,name)<0)
graphic.Create(chart,name,0,0,0,780,380);
else
graphic.Attach(chart,name);
graphic.BackgroundMain(StringFormat("Geometric distribution p=%G",p_par));
graphic.BackgroundMainSize(16);
//--- disable automatic scaling of the X axis
graphic.XAxis().AutoScale(false);
graphic.XAxis().Max(max);
graphic.XAxis().Min(min);
//--- plot all curves
graphic.CurveAdd(x,y,CURVE_HISTOGRAM,"Sample").HistogramWidth(6);
//--- and now plot the theoretical curve of the distribution density
graphic.CurveAdd(x2,y2,CURVE_LINES,"Theory");
graphic.CurvePlotAll();
//--- plot all curves
graphic.Update();
}
//+------------------------------------------------------------------+
//| Calculate frequencies for data set |
//+------------------------------------------------------------------+
bool CalculateHistogramArray(const double &data[],double &intervals[],double &frequency[],
double &maxv,double &minv,const int cells=10)
{
if(cells<=1) return (false);
int size=ArraySize(data);
if(size<cells*10) return (false);
minv=data[ArrayMinimum(data)];
maxv=data[ArrayMaximum(data)];
double range=maxv-minv;
double width=range/cells;
if(width==0) return false;
ArrayResize(intervals,cells);
ArrayResize(frequency,cells);
//--- define the interval centers
for(int i=0; i<cells; i++)
{
intervals[i]=minv+i*width;
frequency[i]=0;
}
//--- fill the frequencies of falling within the interval
for(int i=0; i<size; i++)
{
int ind=int((data[i]-minv)/width);
if(ind>=cells) ind=cells-1;
frequency[ind]++;
}
return (true);
}
//+------------------------------------------------------------------+
//| Calculates values for sequence generation |
//+------------------------------------------------------------------+

```

--------------------------------

### Set DirectX Shader

Source: https://www.mql5.com/en/docs/directx/dxcontextcreate

Binds a shader to the graphics pipeline. This selects which shader program will be executed for subsequent drawing operations. Requires a valid context handle.

```MQL5
void DXShaderSet(
  int context_handle, // handle of the graphic context
  int shader_handle   // handle of the shader
);

```

--------------------------------

### MQL5 Helper Function: GetMaxMinStepValues

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/exponential

A helper function to determine the maximum, minimum, and step values for generating sequences. It calculates the absolute range of the sequence to obtain the precision of normalization, which is crucial for plotting and analysis.

```MQL5
void GetMaxMinStepValues(double &maxv, double &minv, double &stepv)
{
    //--- calculate the absolute range of the sequence to obtain the precision of normalization
    // This function's implementation is not fully provided in the original text.
    // It would typically involve calculations based on input data or desired range.
}
```

--------------------------------

### MQL5 OnCalculate for Multiple Time Series

Source: https://www.mql5.com/en/docs/basis/function/events

This form of OnCalculate() is for indicators requiring multiple time series for their calculations. It accepts arrays for time, open, high, low, close prices, tick volume, real volume, and spread, along with total rates and previously calculated bars.

```MQL5
int OnCalculate (const int rates_total, // size of input time series 
const int prev_calculated, // bars handled in previous call 
const datetime& time[], // Time 
const double& open[], // Open 
const double& high[], // High 
const double& low[], // Low 
const double& close[], // Close 
const long& tick_volume[], // Tick Volume 
const long& volume[], // Real Volume 
const int& spread[] // Spread 
);
```

--------------------------------

### Declare Bitmap Resource as 1D Array in MQL5

Source: https://www.mql5.com/en/docs/runtime/resources

Declares a resource variable to hold bitmap data from a BMP file as a one-dimensional array. The array size is calculated as height * width.

```MQL5
#resource "image.bmp" as bitmap ExtBitmap[]
```

--------------------------------

### Set DirectX Shader Inputs

Source: https://www.mql5.com/en/docs/directx/dxcontextcreate

Binds buffers (like vertex or index buffers) to the shader's input slots. This function is used to provide data to the shader for processing. Requires a valid context handle.

```MQL5
void DXShaderInputsSet(
  int context_handle, // handle of the graphic context
  int shader_handle,  // handle of the shader
  int input_slot,     // shader input slot index
  int buffer_handle   // handle of the buffer to bind
);

```

--------------------------------

### Check Symbol Order Modes in MQL5

Source: https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants

This MQL5 function checks and prints the allowed order types for a given trading symbol. It uses SymbolInfoInteger with SYMBOL_ORDER_MODE to retrieve the order mode flags. No external dependencies are required, and it outputs strings indicating allowed order types.

```MQL5
//+------------------------------------------------------------------+
//| The function prints out order types allowed for a symbol |
//+------------------------------------------------------------------+
void Check_SYMBOL_ORDER_MODE(string symbol)
{
//--- receive the value of the property describing allowed order types
int symbol_order_mode=(int)SymbolInfoInteger(symbol,SYMBOL_ORDER_MODE);
//--- check for market orders (Market Execution)
if((SYMBOL_ORDER_MARKET&symbol_order_mode)==SYMBOL_ORDER_MARKET)
Print(symbol+ ": Market orders are allowed (Buy and Sell)");
//--- check for Limit orders
if((SYMBOL_ORDER_LIMIT&symbol_order_mode)==SYMBOL_ORDER_LIMIT)
Print(symbol+ ": Buy Limit and Sell Limit orders are allowed");
//--- check for Stop orders
if((SYMBOL_ORDER_STOP&symbol_order_mode)==SYMBOL_ORDER_STOP)
Print(symbol+ ": Buy Stop and Sell Stop orders are allowed");
//--- check for Stop Limit orders
if((SYMBOL_ORDER_STOP_LIMIT&symbol_order_mode)==SYMBOL_ORDER_STOP_LIMIT)
Print(symbol+ ": Buy Stop Limit and Sell Stop Limit orders are allowed");
//--- check if placing a Stop Loss orders is allowed
if((SYMBOL_ORDER_SL&symbol_order_mode)==SYMBOL_ORDER_SL)
Print(symbol+ ": Stop Loss orders are allowed");
//--- check if placing a Take Profit orders is allowed
if((SYMBOL_ORDER_TP&symbol_order_mode)==SYMBOL_ORDER_TP)
Print(symbol+ ": Take Profit orders are allowed");
//--- check if closing a position by an opposite one is allowed
if((SYMBOL_ORDER_TP&symbol_order_mode)==SYMBOL_ORDER_CLOSEBY)
Print(symbol+ ": Close by allowed");
//--- 
}
```

--------------------------------

### Calculate Max, Min, and Step Values for Sequence Generation (MQL5)

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/noncentralfisher

This MQL5 function calculates the maximum, minimum, and step values required for sequence generation. It normalizes values based on the absolute range and logarithm of the range to determine the appropriate precision. The step value is adjusted to ensure at least 10 steps within the range.

```MQL5
//+------------------------------------------------------------------+
//| Calculates values for sequence generation |
//+------------------------------------------------------------------+
void GetMaxMinStepValues(double &maxv,double &minv,double &stepv)
{
//--- calculate the absolute range of the sequence to obtain the precision of normalization
  double range=MathAbs(maxv-minv);
  int degree=(int)MathRound(MathLog10(range));
//--- normalize the maximum and minimum values to the specified precision
  maxv=NormalizeDouble(maxv,degree);
  minv=NormalizeDouble(minv,degree);
//--- sequence generation step is also set based on the specified precision
  stepv=NormalizeDouble(MathPow(10,-degree),degree);
  if((maxv-minv)/stepv<10)
    stepv/=10.;
}
```

--------------------------------

### MQL5 OnBookEvent: Depth of Market Change Notification

Source: https://www.mql5.com/en/docs/basis/function/events

The OnBookEvent() function is the handler for the BookEvent, triggered when the Depth of Market changes for a subscribed symbol. It receives the symbol name as a string parameter and is broadcast to all EAs with this handler.

```MQL5
void OnBookEvent(const string& symbol)
{
  // Handle Depth of Market changes for the given symbol
  // Requires prior subscription using MarketBookAdd()
}
```

--------------------------------

### Release DirectX Handle with DXRelease (MQL5)

Source: https://www.mql5.com/en/docs/directx/dxrelease

The DXRelease function in MQL5 is used to release a previously created DirectX handle. It takes the handle identifier as input and returns a boolean indicating success or failure. It is essential to call this function for all handles that are no longer in use to manage resources effectively.

```MQL5
bool DXRelease(
  int handle // handle
);
```

--------------------------------

### Retrieve and Display Orders by Symbol Group using Python

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5ordersget_py

This Python code snippet shows how to retrieve active orders for symbols whose names contain a specific pattern (e.g., '*GBP*') using the group parameter. It then displays these orders in a formatted table using pandas DataFrame, dropping unnecessary columns and converting timestamps.

```python
import MetaTrader5 as mt5
import pandas as pd

pd.set_option('display.max_columns', 500)
pd.set_option('display.width', 1500)

if not mt5.initialize():
    print("initialize() failed, error code =", mt5.last_error())
    quit()

gbp_orders=mt5.orders_get(group="*GBP*")
if gbp_orders is None:
    print("No orders with group=\"*GBP*\", error code={}".format(mt5.last_error()))
else:
    print("orders_get(group=\"*GBP*\")={}".format(len(gbp_orders)))
    df=pd.DataFrame(list(gbp_orders),columns=gbp_orders[0]._asdict().keys())
    df.drop(['time_done', 'time_done_msc', 'position_id', 'position_by_id', 'reason', 'volume_initial', 'price_stoplimit'], axis=1, inplace=True)
    df['time_setup'] = pd.to_datetime(df['time_setup'], unit='s')
    print(df)

mt5.shutdown()
```

--------------------------------

### Calculate Binomial Distribution Histogram (MQL5)

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/binomial

This script calculates and plots a histogram for a sample of random numbers generated from a binomial distribution, alongside the theoretical probability density curve. It utilizes functions from the Math, Stat, and Graphics libraries.

```MQL5
#include <Graphics\Graphic.mqh>
#include <Math\Stat\Binomial.mqh>
#include <Math\Stat\Math.mqh>

#property script_show_inputs

input double n_par=40; // the number of tests
input double p_par=0.75; // probability of success for each test

void OnStart()
{
    ChartSetInteger(0,CHART_SHOW,false);
    MathSrand(GetTickCount());

    int n = 1000000; // the number of values in the sample
    int ncells = 20; // the number of intervals in the histogram
    double x[]; // centers of the histogram intervals
    double y[]; // the number of values from the sample falling within the interval
    double data[]; // sample of random values
    double max, min; // the maximum and minimum values in the sample

    // Obtain a sample from the binomial distribution
    MathRandomBinomial(n_par, p_par, n, data);

    // Calculate the data to plot the histogram
    CalculateHistogramArray(data, x, y, max, min, ncells);

    // Obtain the theoretically calculated data at the interval of [min,max]
    double x2[];
    double y2[];
    MathSequence(0, n_par, 1, x2);
    MathProbabilityDensityBinomial(x2, n_par, p_par, false, y2);

    // Set the scale
    double theor_max = y2[ArrayMaximum(y2)];
    double sample_max = y[ArrayMaximum(y)];
    double k = sample_max / theor_max;
    for (int i = 0; i < ncells; i++)
        y[i] /= k;

    // Output charts
    CGraphic graphic;
    string name = "GraphicNormal";
    if (ObjectFind(0, name) < 0)
        graphic.Create(0, name, 0, 0, 0, 780, 380);
    else
        graphic.Attach(0, name);

    graphic.BackgroundMain(StringFormat("Binomial distribution\nn=%G p=%G", n_par, p_par));
    graphic.BackgroundMainSize(16);

    // Plot all curves
    graphic.CurveAdd(x, y, CURVE_HISTOGRAM, "Sample").HistogramWidth(6);
    // and now plot the theoretical curve of the distribution density
    graphic.CurveAdd(x2, y2, CURVE_LINES, "Theory").LinesSmooth(true);
    graphic.CurvePlotAll();
    graphic.Update();
}

//+------------------------------------------------------------------+
//| Calculate frequencies for data set |
//+------------------------------------------------------------------+
bool CalculateHistogramArray(const double &data[], double &intervals[], double &frequency[],
                            double &maxv, double &minv, const int cells = 10)
{
    if (cells <= 1) return (false);
    int size = ArraySize(data);
    if (size < cells * 10) return (false);

    minv = data[ArrayMinimum(data)];
    maxv = data[ArrayMaximum(data)];
    double range = maxv - minv;
    double width = range / cells;
    if (width == 0) return false;

    ArrayResize(intervals, cells);
    ArrayResize(frequency, cells);

    // Define the interval centers
    for (int i = 0; i < cells; i++)
    {
        intervals[i] = minv + (i + 0.5) * width;
        frequency[i] = 0;
    }

    // Fill the frequencies of falling within the interval
    for (int i = 0; i < size; i++)
    {
        int ind = int((data[i] - minv) / width);
        if (ind >= cells) ind = cells - 1;
        frequency[ind]++;
    }
    return (true);
}
```

--------------------------------

### Set DirectX Primitive Topology

Source: https://www.mql5.com/en/docs/directx/dxcontextcreate

Sets the type of primitives (e.g., triangles, lines) that will be rendered by subsequent draw calls. Requires a valid context handle.

```MQL5
void DXPrimiveTopologySet(
  int context_handle,       // handle of the graphic context
  uint topology_type        // primitive topology type (e.g., PRIMITIVE_TOPOLOGY_TRIANGLELIST)
);

```

--------------------------------

### Shut Down MetaTrader 5 Connection

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5historyordersget_py

This snippet demonstrates how to properly close the connection to the MetaTrader 5 terminal using the `shutdown()` method from the MetaTrader5 library. This is crucial for releasing resources and ensuring a clean exit from the application. No specific inputs are required, and the output is the successful termination of the connection.

```python
# shut down connection to the MetaTrader 5 terminal
from metatrader5 import MetaTrader5

mq = MetaTrader5()
# ... other operations ...
mq.shutdown()

```

--------------------------------

### MQL5: Modify Stop Loss and Take Profit for Open Positions

Source: https://www.mql5.com/en/docs/constants/structures/mqltraderequest

This MQL5 script modifies the Stop Loss (SL) and Take Profit (TP) levels for open positions. It iterates through all open positions, checks if the position matches a specific magic number and has SL/TP undefined, calculates new SL/TP levels based on current prices and stop levels, and then sends a TRADE_ACTION_SLTP request to update the position. Error handling for OrderSend is included.

```mql5
#define EXPERT_MAGIC 123456 // MagicNumber of the expert
//+------------------------------------------------------------------+
//| Modification of Stop Loss and Take Profit of position |
//+------------------------------------------------------------------+
void OnStart()
{
//--- declare and initialize the trade request and result of trade request
MqlTradeRequest request;
MqlTradeResult result;
int total=PositionsTotal(); // number of open positions
//--- iterate over all open positions
for(int i=0; i<total; i++)
{
//--- parameters of the order
ulong position_ticket=PositionGetTicket(i);// ticket of the position
string position_symbol=PositionGetString(POSITION_SYMBOL); // symbol
int digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS); // number of decimal places
ulong magic=PositionGetInteger(POSITION_MAGIC); // MagicNumber of the position
double volume=PositionGetDouble(POSITION_VOLUME); // volume of the position
double sl=PositionGetDouble(POSITION_SL); // Stop Loss of the position
double tp=PositionGetDouble(POSITION_TP); // Take Profit of the position
ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE); // type of the position
//--- output information about the position
PrintFormat("#%I64u %s %s %.2f %s sl: %s tp: %s [\t%I64d]",
position_ticket,
position_symbol,
EnumToString(type),
volume,
DoubleToString(PositionGetDouble(POSITION_PRICE_OPEN),digits),
DoubleToString(sl,digits),
DoubleToString(tp,digits),
magic);
//--- if the MagicNumber matches, Stop Loss and Take Profit are not defined
if(magic==EXPERT_MAGIC && sl==0 && tp==0)
{
//--- calculate the current price levels
double price=PositionGetDouble(POSITION_PRICE_OPEN);
double bid=SymbolInfoDouble(position_symbol,SYMBOL_BID);
double ask=SymbolInfoDouble(position_symbol,SYMBOL_ASK);
int stop_level=(int)SymbolInfoInteger(position_symbol,SYMBOL_TRADE_STOPS_LEVEL);
double price_level;
//--- if the minimum allowed offset distance in points from the current close price is not set
if(stop_level<=0)
stop_level=150; // set the offset distance of 150 points from the current close price
else
stop_level+=50; // set the offset distance to (SYMBOL_TRADE_STOPS_LEVEL + 50) points for reliability

//--- calculation and rounding of the Stop Loss and Take Profit values
price_level=stop_level*SymbolInfoDouble(position_symbol,SYMBOL_POINT);
if(type==POSITION_TYPE_BUY)
{
sl=NormalizeDouble(bid-price_level,digits);
tp=NormalizeDouble(bid+price_level,digits);
}
else
{
sl=NormalizeDouble(ask+price_level,digits);
tp=NormalizeDouble(ask-price_level,digits);
}
//--- zeroing the request and result values
ZeroMemory(request);
ZeroMemory(result);
//--- setting the operation parameters
request.action =TRADE_ACTION_SLTP; // type of trade operation
request.position=position_ticket; // ticket of the position
request.symbol=position_symbol; // symbol
request.sl =sl; // Stop Loss of the position
request.tp =tp; // Take Profit of the position
request.magic=EXPERT_MAGIC; // MagicNumber of the position
//--- output information about the modification
PrintFormat("Modify #%I64d %s %s",position_ticket,position_symbol,EnumToString(type));
//--- send the request
if(!OrderSend(request,result))
PrintFormat("OrderSend error %d",GetLastError()); // if unable to send the request, output the error code
//--- information about the operation
PrintFormat("retcode=%u deal=%I64u order=%I64u",result.retcode,result.deal,result.order);
}
}
}
//+------------------------------------------------------------------+

```

--------------------------------

### Histogram Calculation and Plotting with Noncentral F-distribution (MQL5)

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/noncentralfisher

Demonstrates how to generate a sample of noncentral F-distributed random numbers, calculate a histogram for this sample, and plot both the sample histogram and the theoretical probability density curve. This involves using MathRandomNoncentralF, CalculateHistogramArray, and MathProbabilityDensityNoncentralF along with the CGraphic class for visualization.

```MQL5
#include <Graphics\Graphic.mqh>
#include <Math\Stat\NoncentralF.mqh>
#include <Math\Stat\Math.mqh>

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   //--- input parameters
   input double nu_1=20; // the first number of degrees of freedom
   input double nu_2=20; // the second number of degrees of freedom
   input double sig=10; // noncentrality parameter
   
   //--- initialize the random number generator
   MathSrand(GetTickCount());
   
   //--- generate a sample of the random variable
   int n=1000000; // the number of values in the sample
   int ncells=51; // the number of intervals in the histogram
   double x[]; // centers of the histogram intervals
   double y[]; // the number of values from the sample falling within the interval
   double data[]; // sample of random values
   double max,min; // the maximum and minimum values in the sample
   
   //--- obtain a sample from the noncentral Fisher's F-distribution
   MathRandomNoncentralF(nu_1,nu_2,sig,n,data);
   
   //--- calculate the data to plot the histogram
   CalculateHistogramArray(data,x,y,max,min,ncells);
   
   //--- obtain the sequence boundaries and the step for plotting the theoretical curve
   double step;
   GetMaxMinStepValues(max,min,step);
   step=MathMin(step,(max-min)/ncells);
   
   //--- obtain the theoretically calculated data at the interval of [min,max]
   double x2[];
   double y2[];
   MathSequence(min,max,step,x2);
   MathProbabilityDensityNoncentralF(x2,nu_1,nu_2,sig,false,y2);
   
   //--- set the scale and plot curves
   // ... (scaling and CGraphic plotting code as in the original example) ...
}

//+------------------------------------------------------------------+
//| Calculate frequencies for data set                               |
//+------------------------------------------------------------------+
bool CalculateHistogramArray(const double &data[],double &intervals[],double &frequency[],
                             double &maxv,double &minv,const int cells=10)
{
   // ... (implementation as in the original example) ...
   return (true);
}

//+------------------------------------------------------------------+
//| Helper function to get max, min, and step values                 |
//+------------------------------------------------------------------+
void GetMaxMinStepValues(double &max, double &min, double &step)
{
   // Placeholder for actual implementation if not provided elsewhere
   // Example: calculate based on data range if needed
   max = 10.0;
   min = 0.0;
   step = 0.1;
}

```

--------------------------------

### MQL5 MqlTradeRequest Structure Definition

Source: https://www.mql5.com/en/docs/constants/structures/mqltraderequest

Defines the MqlTradeRequest structure used in MQL5 for trade operations. This structure contains all necessary fields for placing and managing trade deals, including action type, symbol, volume, prices, and order parameters.

```MQL5
struct MqlTradeRequest {
  ENUM_TRADE_REQUEST_ACTIONS action; // Trade operation type
  ulong magic; // Expert Advisor ID (magic number)
  ulong order; // Order ticket
  string symbol; // Trade symbol
  double volume; // Requested volume for a deal in lots
  double price; // Price
  double stoplimit; // StopLimit level of the order
  double sl; // Stop Loss level of the order
  double tp; // Take Profit level of the order
  ulong deviation; // Maximal possible deviation from the requested price
  ENUM_ORDER_TYPE type; // Order type
  ENUM_ORDER_TYPE_FILLING type_filling; // Order execution type
  ENUM_ORDER_TYPE_TIME  type_time; // Order expiration type
  datetime expiration; // Order expiration time (for the orders of ORDER_TIME_SPECIFIED type)
  string comment; // Order comment
  ulong position; // Position ticket
  ulong position_by; // The ticket of an opposite position
};

```

--------------------------------

### Generate Binomial Distribution Random Numbers (MQL5)

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/binomial

Generates pseudorandom numbers distributed according to the binomial law. This function can generate a single random variable or an array of pseudorandom variables. It requires the number of tests (n), probability of success (p), and the desired number of random values to generate.

```MQL5
#include <Math\Stat\Binomial.mqh>

// Example usage:
double n_par = 10;
double p_par = 0.3;
int num_samples = 1000;
double random_data[];

MathRandomBinomial(n_par, p_par, num_samples, random_data);
// random_data array will be filled with pseudorandom numbers from the binomial distribution
```

--------------------------------

### Calculate Beta Distribution Moments (MQL5)

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/beta

Calculates the theoretical numerical values of the first four moments (mean, variance, skewness, kurtosis) of the beta distribution. This function requires the shape parameters alpha and beta, and an output array to store the calculated moments.

```MQL5
#include <Math\Stat\Beta.mqh>

// Example usage (assuming alpha, beta are defined):
// double alpha = 2.0;
// double beta = 5.0;
// double moments[4]; // Array to store mean, variance, skewness, kurtosis
// MathMomentsBeta(alpha, beta, moments);
// double mean = moments[0];
// double variance = moments[1];

```

--------------------------------

### MQL5: Normalize and Scale Values based on Range

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/chisquare

This MQL5 code normalizes maximum and minimum values to a calculated precision (degree) and determines a scaling step. It adjusts the step size if the resulting number of steps is less than 10. Dependencies include MQL5 built-in functions like MathAbs, MathLog10, MathRound, NormalizeDouble, MathPow.

```mql5
double range=MathAbs(maxv-minv);
int degree=(int)MathRound(MathLog10(range));
//--- normalize the maximum and minimum values to the specified precision
maxv=NormalizeDouble(maxv,degree);
minv=NormalizeDouble(minv,degree);
//--- sequence generation step is also set based on the specified precision
stepv=NormalizeDouble(MathPow(10,-degree),degree);
if((maxv-minv)/stepv<10)
stepv/=10.;
```

--------------------------------

### MQL5: Deleting Dynamically Created Objects

Source: https://www.mql5.com/en/docs/basis/types/classes

This snippet shows how to deallocate memory for dynamically created objects in MQL5 using the 'delete' keyword. It also includes comments explaining when explicit deletion is not necessary due to object lifetime management or shared references.

```MQL5
//--- Delete dynamically created arrays
delete pfoo6;
delete pfoo7;
//delete pfoo8; // You do not need to delete pfoo8 explicitly, since it points to the automatically created object foo1
//delete pfoo9; // You do not need to delete pfoo9 explicitly. since it points to the same object as pfoo7
```

--------------------------------

### Stop Sound Playback in MQL5

Source: https://www.mql5.com/en/docs/runtime/resources

Demonstrates the method to stop any currently playing sound initiated by the PlaySound() function in MQL5. This is achieved by calling PlaySound() with a NULL parameter.

```MQL5
//--- call of PlaySound() with NULL parameter stops playback
PlaySound(NULL);
```

--------------------------------

### MQL5 MqlTick Structure Definition

Source: https://www.mql5.com/en/docs/constants/structures/mqltick

Defines the MqlTick structure, used to store the latest price update information for a financial symbol. It includes fields for time, bid, ask, last price, volume, and millisecond timestamp.

```MQL5
struct MqlTick {
    datetime  time; // Time of the last prices update
    double bid; // Current Bid price
    double ask; // Current Ask price
    double last; // Price of the last deal (Last)
    ulong volume; // Volume for the current Last price
    long time_msc; // Time of a price last update in milliseconds
    uint  flags; // Tick flags
    double volume_real; // Volume for the current Last price with greater accuracy
};
```

--------------------------------

### MQL5 Sequence Normalization and Calculation

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/beta

Calculates the absolute range of a sequence, determines the normalization precision (degree), and normalizes the maximum and minimum values accordingly. It also sets the sequence generation step based on the calculated precision.

```MQL5
//--- calculate the absolute range of the sequence to obtain the precision of normalization   
double range=MathAbs(maxv-minv);
int degree=(int)MathRound(MathLog10(range));
//--- normalize the maximum and minimum values to the specified precision   
maxv=NormalizeDouble(maxv,degree);
minv=NormalizeDouble(minv,degree);
//--- sequence generation step is also set based on the specified precision   
stepv=NormalizeDouble(MathPow(10,-degree),degree);
if((maxv-minv)/stepv<10)
stepv/=10.;
}
```

--------------------------------

### MQL5 OpenCL Context Cleanup Function

Source: https://www.mql5.com/en/docs/opencl/clbufferwrite

Frees all resources allocated for OpenCL operations, including buffers, kernel, program, and context. This function ensures proper cleanup to prevent memory leaks.

```MQL5
//+------------------------------------------------------------------+
//| Release all OpenCL contexts |
//+------------------------------------------------------------------+
void CLFreeAll(int cl_ctx, int cl_prg, int cl_krn,
int cl_mem_in1, int cl_mem_in2, int cl_mem_out)
{
//--- delete all contexts created by OpenCL in reverse order   
CLBufferFree(cl_mem_in1);
CLBufferFree(cl_mem_in2);
CLBufferFree(cl_mem_out);
CLKernelFree(cl_krn);
CLProgramFree(cl_prg);
CLContextFree(cl_ctx);
}
```

--------------------------------

### MQL5 TradeResultDescription Function

Source: https://www.mql5.com/en/docs/constants/structures/mqltradetransaction

This MQL5 function takes a MqlTradeResult structure as input and returns a formatted string containing key details about the trade request's outcome. It includes information such as the return code, request ID, order and deal tickets, volume, price, ask, bid, and any associated comment. This is useful for logging or displaying trade execution results.

```MQL5
//+------------------------------------------------------------------+
//| Returns the textual description of the request handling result |
//+------------------------------------------------------------------+
string TradeResultDescription(const MqlTradeResult &result)
{
//---
string desc="Retcode "+(string)result.retcode+"\r\n";
desc+="Request ID: "+StringFormat("%d",result.request_id)+"\r\n";
desc+="Order ticket: "+(string)result.order+"\r\n";
desc+="Deal ticket: "+(string)result.deal+"\r\n";
desc+="Volume: "+StringFormat("%G",result.volume)+"\r\n";
desc+="Price: "+StringFormat("%G",result.price)+"\r\n";
desc+="Ask: "+StringFormat("%G",result.ask)+"\r\n";
desc+="Bid: "+StringFormat("%G",result.bid)+"\r\n";
desc+="Comment: "+result.comment+"\r\n";
//---
return desc;
}
```

--------------------------------

### MQL5 OnTester: Custom Optimization Criterion

Source: https://www.mql5.com/en/docs/basis/function/events

The OnTester() function is called after history testing of an Expert Advisor is complete. It returns a double value used as a custom maximum optimization criterion in genetic optimization. This value helps in sorting and filtering results across generations.

```MQL5
double OnTester()
{
  // Custom logic to calculate and return an optimization criterion
  return 0.0; // Placeholder
}
```

--------------------------------

### Fetch and Display Deals by Position ID

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5historydealsget_py

This code snippet retrieves all deals associated with a specific MetaTrader 5 position ID using the `history_deals_get` function. It includes error handling for cases where no deals are found for the given position. The retrieved deals are then converted into a pandas DataFrame for easy viewing and analysis.

```python
# get all deals related to the position #530218319
position_id=530218319
position_deals = mt5.history_deals_get(position=position_id)
if position_deals == None:
    print("No deals with position #{}".format(position_id))
    print("error code =", mt5.last_error())
elif len(position_deals) > 0:
    print("Deals with position id #{}: {}".format(position_id, len(position_deals)))
    # display these deals as a table using pandas.DataFrame
    df=pd.DataFrame(list(position_deals),columns=position_deals[0]._asdict().keys())
    df['time'] = pd.to_datetime(df['time'], unit='s')
    print(df)
```

--------------------------------

### Normalize MQL5 Data with Precision

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/cauchy

This snippet normalizes maximum and minimum values (maxv, minv) of a sequence to a calculated precision (degree). It determines the precision based on the absolute range of the sequence and then normalizes the values and calculates the sequence generation step (stepv).

```MQL5
//--- calculate the absolute range of the sequence to obtain the precision of normalization   
double range=MathAbs(maxv-minv);   
int degree=(int)MathRound(MathLog10(range));   
//--- normalize the maximum and minimum values to the specified precision   
maxv=NormalizeDouble(maxv,degree);   
minv=NormalizeDouble(minv,degree);   
//--- sequence generation step is also set based on the specified precision   
stepv=NormalizeDouble(MathPow(10,-degree),degree);   
if((maxv-minv)/stepv<10)   
stepv/=10.;   
}
```

--------------------------------

### Retrieving Order Volume Filling Policy in MQL5

Source: https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties

Shows how to retrieve the volume filling policy of an active or completed order using MQL5. The OrderGetInteger() or HistoryOrderGetInteger() functions with the ORDER_TYPE_FILLING modifier are used.

```MQL5
long filling_type = OrderGetInteger(ORDER_TYPE_FILLING); // For active orders
// or
long filling_type_history = HistoryOrderGetInteger(order_ticket, ORDER_TYPE_FILLING); // For historical orders
```

--------------------------------

### MQL5 Statistical Functions

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/cauchy

This entry lists utility functions available in MQL5 for statistical analysis, including calculating moments of a logistic distribution and the probability density function of a Cauchy distribution.

```MQL5
MathMomentsLogistic
```

```MQL5
MathProbabilityDensityCauchy
```

--------------------------------

### MQL5 Log-Normal Distribution Functions

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/lognormal

These MQL5 functions facilitate calculations related to the log-normal distribution. They allow for determining probability density, cumulative distribution values, inverse distribution (quantiles), and generating random numbers. The library also supports array-based operations for these calculations. Dependencies include standard MQL5 math and graphics libraries.

```MQL5
#include <Graphics\Graphic.mqh>
#include <Math\Stat\Lognormal.mqh>
#include <Math\Stat\Math.mqh>

#property script_show_inputs

//--- input parameters
input double mean_value=1.0; // logarithm of the expected value (log mean)
input double std_dev=0.25; // logarithm of the root-mean-square deviation (log standard deviation)

//+------------------------------------------------------------------+
//| Script program start function |
//+------------------------------------------------------------------+
void OnStart()
{
//--- hide the price chart
ChartSetInteger(0,CHART_SHOW,false);
//--- initialize the random number generator 
MathSrand(GetTickCount());
//--- generate a sample of the random variable
long chart=0;
string name="GraphicNormal";
int n=1000000; // the number of values in the sample
int ncells=51; // the number of intervals in the histogram
double x[]; // centers of the histogram intervals
double y[]; // the number of values from the sample falling within the interval
double data[]; // sample of random values
double max,min; // the maximum and minimum values in the sample
//--- obtain a sample from the log-normal distribution
MathRandomLognormal(mean_value,std_dev,n,data);
//--- calculate the data to plot the histogram
CalculateHistogramArray(data,x,y,max,min,ncells);
//--- obtain the sequence boundaries and the step for plotting the theoretical curve
double step;
GetMaxMinStepValues(max,min,step);
step=MathMin(step,(max-min)/ncells); 
//--- obtain the theoretically calculated data at the interval of [min,max]
double x2[];
double y2[];
MathSequence(min,max,step,x2);
MathProbabilityDensityLognormal(x2,mean_value,std_dev,false,y2);
//--- set the scale
double theor_max=y2[ArrayMaximum(y2)];
double sample_max=y[ArrayMaximum(y)];
double k=sample_max/theor_max;
for(int i=0; i<ncells; i++)
 y[i]/=k;
//--- output charts
CGraphic graphic;
if(ObjectFind(chart,name)<0)
 graphic.Create(chart,name,0,0,0,780,380);
else
 graphic.Attach(chart,name);
graphic.BackgroundMain(StringFormat("Lognormal distribution mu=%G sigma=%G",mean_value,std_dev));
graphic.BackgroundMainSize(16);
//--- disable automatic scaling of the Y axis
graphic.YAxis().AutoScale(false);
graphic.YAxis().Max(theor_max);
graphic.YAxis().Min(0); 
//--- plot all curves
graphic.CurveAdd(x,y,CURVE_HISTOGRAM,"Sample").HistogramWidth(6);
//--- and now plot the theoretical curve of the distribution density
graphic.CurveAdd(x2,y2,CURVE_LINES,"Theory");
graphic.CurvePlotAll();
//--- plot all curves
graphic.Update();
}
//+------------------------------------------------------------------+
//| Calculate frequencies for data set |
//+------------------------------------------------------------------+
bool CalculateHistogramArray(const double &data[],double &intervals[],double &frequency[], 
double &maxv,double &minv,const int cells=10)
{
if(cells<=1) return (false);
int size=ArraySize(data);
if(size<cells*10) return (false);
minv=data[ArrayMinimum(data)];
maxv=data[ArrayMaximum(data)];
double range=maxv-minv;
double width=range/cells;
if(width==0) return false;
ArrayResize(intervals,cells);
ArrayResize(frequency,cells);
//--- define the interval centers
for(int i=0; i<cells; i++)
{
intervals[i]=minv+(i+0.5)*width;
frequency[i]=0;
}
//--- fill the frequencies of falling within the interval
for(int i=0; i<size; i++)
{
int ind=int((data[i]-minv)/width);
if(ind>=cells) ind=cells-1;
frequency[ind]++;
}
return (true);
}

```

--------------------------------

### Setting Volume Filling Policy in MQL5 OrderSend()

Source: https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties

Demonstrates how to set the volume execution policy when sending a trade request using the OrderSend() function in MQL5. The 'type_filling' field within the MqlTradeRequest structure is used for this purpose.

```MQL5
MqlTradeRequest request;
request.type_filling = ORDER_FILLING_FOK; // Example: Set to Fill or Kill
```

--------------------------------

### MQL5 OnTick Event Function

Source: https://www.mql5.com/en/docs/basis/function/events

The OnTick() function is called for Expert Advisors when a new tick for a symbol is received on the attached chart. It is declared as a void function with no parameters and is not applicable to custom indicators or scripts.

```MQL5
void OnTick();
```

--------------------------------

### Matrix Square Root Calculation in MQL5

Source: https://www.mql5.com/en/docs/math

Demonstrates how to calculate the element-wise square root of a matrix using the MathSqrt function in MQL5. This function is applicable to matrices and vectors, performing the operation on each element individually.

```MQL5
//---
matrix a= {{1, 4}, {9, 16}};   
Print("matrix a=\n",a);

a=MathSqrt(a);   
Print("MatrSqrt(a)=\n",a);
/*   
matrix a=   
[[1,4]   
[9,16]]   
MatrSqrt(a)=   
[[1,2]   
[3,4]]   
*/  
---
```

--------------------------------

### Math Moments Normal Functions (MQL5)

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/lognormal

This snippet lists MQL5 functions related to mathematical moments and normal probability distributions. These functions are typically used for statistical analysis and modeling.

```MQL5
MathMomentsNormal
MathProbabilityDensityLognormal
```

--------------------------------

### Plot EURAUD Ticks Data

Source: https://www.mql5.com/en/docs/python_metatrader5

Visualizes the fetched EURAUD tick data using matplotlib and pandas. It converts the time data to datetime format and plots the ask and bid prices, along with a legend and title.

```python
# create DataFrame out of the obtained data
ticks_frame = pd.DataFrame(euraud_ticks)
# convert time in seconds into the datetime format
ticks_frame['time']=pd.to_datetime(ticks_frame['time'], unit='s')
# display ticks on the chart
plt.plot(ticks_frame['time'], ticks_frame['ask'], 'r-', label='ask')
plt.plot(ticks_frame['time'], ticks_frame['bid'], 'b-', label='bid')

# display the legends
plt.legend(loc='upper left')

# add the header
plt.title('EURAUD ticks')

```

--------------------------------

### copy_rates_range

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5copyratesrange_py

Retrieves historical price bars for a financial instrument within a specified date range and timeframe from the MetaTrader 5 terminal.

```APIDOC
## GET /copy_rates_range

### Description
This function retrieves historical price data (bars) for a specified financial instrument, timeframe, and date range from the MetaTrader 5 terminal. It is useful for backtesting trading strategies or analyzing historical market behavior.

### Method
GET (conceptual, as this is a Python function call)

### Endpoint
N/A (Python function)

### Parameters
#### Path Parameters
None

#### Query Parameters
None

#### Request Body
None

### Parameters
*   **symbol** (string) - Required - The name of the financial instrument (e.g., "EURUSD").
*   **timeframe** (enum) - Required - The timeframe for the bars. Use values from the `mt5.TIMEFRAME_` enumeration (e.g., `mt5.TIMEFRAME_M5` for 5-minute bars).
*   **date_from** (datetime or int) - Required - The starting date and time for the requested bars. Can be a Python `datetime` object (preferably in UTC) or a Unix timestamp (seconds since 1970-01-01). Bars with an open time greater than or equal to `date_from` will be returned.
*   **date_to** (datetime or int) - Required - The ending date and time for the requested bars. Can be a Python `datetime` object (preferably in UTC) or a Unix timestamp (seconds since 1970-01-01). Bars with an open time less than or equal to `date_to` will be returned.

### Request Example
```python
from datetime import datetime
import MetaTrader5 as mt5
import pytz

# Establish connection to MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed, error code =", mt5.last_error())
    quit()

# Set time zone to UTC for accurate time handling
timezone = pytz.timezone("Etc/UTC")

# Define the date range in UTC
utc_from = datetime(2020, 1, 10, tzinfo=timezone)
utc_to = datetime(2020, 1, 11, hour=13, tzinfo=timezone)

# Get rates for EURUSD, M5 timeframe, within the specified UTC range
rates = mt5.copy_rates_range("EURUSD", mt5.TIMEFRAME_M5, utc_from, utc_to)

# Shut down connection
mt5.shutdown()

# Process the returned rates (numpy array)
if rates is not None:
    print(f"Successfully retrieved {len(rates)} bars.")
    # Example: print the first 5 bars
    for i in range(min(5, len(rates))):
        print(rates[i])
else:
    print(f"Error retrieving rates: {mt5.last_error()}")
```

### Response
#### Success Response (200)
Returns a numpy array containing the historical bars. Each bar is an object with the following fields:
*   **time** (int) - Unix timestamp of the bar's open time (UTC).
*   **open** (float) - The opening price of the bar.
*   **high** (float) - The highest price during the bar's period.
*   **low** (float) - The lowest price during the bar's period.
*   **close** (float) - The closing price of the bar.
*   **tick_volume** (int) - The volume of ticks during the bar.
*   **spread** (int) - The spread at the time the bar opened.
*   **real_volume** (int) - The real volume traded during the bar.

Returns `None` in case of an error. Error details can be retrieved using `mt5.last_error()`.

#### Response Example
```json
[
  {"time": 1578610800, "open": 1.11001, "high": 1.11050, "low": 1.11000, "close": 1.11025, "tick_volume": 150, "spread": 10, "real_volume": 50},
  {"time": 1578611100, "open": 1.11025, "high": 1.11080, "low": 1.11020, "close": 1.11060, "tick_volume": 180, "spread": 12, "real_volume": 65},
  ...
]
```

### Error Handling
*   If the connection to the MetaTrader 5 terminal fails, `mt5.initialize()` will return `False`, and `mt5.last_error()` can be used to get the error code.
*   If `copy_rates_range()` fails to retrieve data, it will return `None`. Use `mt5.last_error()` to diagnose the issue (e.g., invalid symbol, timeframe, or date range, or insufficient history available).
*   Ensure `datetime` objects used for `date_from` and `date_to` are timezone-aware, preferably set to UTC, as MetaTrader 5 operates on UTC time.

```

--------------------------------

### MQL5 order_send Function Signature

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5ordersend_py

The `order_send` function in MQL5 is used to submit trading requests to the trade server. It accepts an `MqlTradeRequest` structure as input and returns an `MqlTradeResult` structure.

```mql5
order_send(
request // request structure
);
```

--------------------------------

### Configuring Plot Properties in MQL5

Source: https://www.mql5.com/en/docs/customind

Illustrates how to set properties for individual plots within an indicator using PlotIndexSetDouble, PlotIndexSetInteger, and PlotIndexSetString. This allows customization of appearance and behavior for each plotted line or shape.

```mql5
void PlotIndexSetDouble(int plot_index, int prop_id, double value);
void PlotIndexSetInteger(int plot_index, int prop_id, long value);
void PlotIndexSetString(int plot_index, int prop_id, const string &value);
```

--------------------------------

### DXShaderSetLayout

Source: https://www.mql5.com/en/docs/directx/dxshadersetlayout

Sets the vertex layout for a given vertex shader. This function defines how vertex data is structured and interpreted by the shader.

```APIDOC
## DXShaderSetLayout

### Description
Sets vertex layout for the vertex shader.

### Method
`bool DXShaderSetLayout(int shader, const DXVertexLayout& layout[]);`

### Endpoint
N/A (This is a function call, not a REST endpoint)

### Parameters
#### Path Parameters
N/A

#### Query Parameters
N/A

#### Request Body
- **shader** (int) - Required - Handle of a vertex shader created in `DXShaderCreate()`.
- **layout[]** (const DXVertexLayout&) - Required - Array of vertex fields description. The description is set by the `DXVertexLayout` structure.
  `struct DXVertexLayout {
    string semantic_name; // The HLSL semantic associated with this element in a shader input-signature.
    uint semantic_index; // The semantic index for the element. A semantic index modifies a semantic, with an integer index number. A semantic index is only needed in a case where there is more than one element with the same semantic.
    ENUM_DX_FORMAT format; // The data type of the element data.
  };`

### Request Example
```json
{
  "shader": 1,
  "layout": [
    {
      "semantic_name": "POSITION",
      "semantic_index": 0,
      "format": "DXGI_FORMAT_R32G32B32_FLOAT"
    },
    {
      "semantic_name": "COLOR",
      "semantic_index": 0,
      "format": "DXGI_FORMAT_R32G32B32A32_FLOAT"
    }
  ]
}
```

### Response
#### Success Response (200)
- **return value** (bool) - Returns `true` if successful, `false` otherwise.

#### Response Example
```json
{
  "return_value": true
}
```

### Note
The layout should match the type of vertices in a specified vertex buffer. It should also match the input type of vertices used at the entry point in the vertex shader code. The vertex buffer for a shader is set in `DXBufferSet()`. The `DXVertexLayout` structure is a version of the `D3D11_INPUT_ELEMENT_DESC` MSDN structure.
```

--------------------------------

### Process MQL5 Order History with Pandas

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5historyordersget_py

This snippet shows how to retrieve order history from MetaTrader 5, process it into a pandas DataFrame, and select relevant columns. It converts time-related fields to datetime objects for easier analysis. Dependencies include the pandas and MetaTrader5 libraries.

```python
# display these orders as a table using pandas.DataFrame
import pandas as pd
from metatrader5 import MetaTrader5

mq = MetaTrader5()

# Assuming position_history_orders is a list of TradeOrder objects
# For demonstration, let's create a dummy list similar to what mt5.history_orders_get might return
class MockTradeOrder:
    def __init__(self, **kwargs):
        self.__dict__.update(kwargs)
    def _asdict(self):
        return self.__dict__

# Example dummy data - replace with actual mt5 call
position_history_orders = [
    MockTradeOrder(ticket=530218319, time_setup=1582282114, time_setup_msc=1582282114681, time_done=1582303777, time_done_msc=1582303777582, time_expiration=0, type_time=0, type_filling=2, state=2, position_by_id=530218319, reason=0, volume_current=0.01, price_stoplimit=0, sl=0, tp=0, volume_initial=0.01, price_open=0.97898, price_current=0.97863, symbol='USDCHF', comment='', external_id=0),
    MockTradeOrder(ticket=535548147, time_setup=1583176242, time_setup_msc=1583176242265, time_done=1583176242, time_done_msc=1583176242265, time_expiration=0, type_time=0, type_filling=0, state=1, position_by_id=530218319, reason=0, volume_current=0.01, price_stoplimit=0, sl=0, tp=0, volume_initial=0.01, price_open=0.95758, price_current=0.95758, symbol='USDCHF', comment='', external_id=0)
]


df=pd.DataFrame(list(position_history_orders),columns=position_history_orders[0]._asdict().keys())
df.drop(['time_expiration','type_time','state','position_by_id','reason','volume_current','price_stoplimit','sl','tp'], axis=1, inplace=True)
df['time_setup'] = pd.to_datetime(df['time_setup'], unit='s')
df['time_done'] = pd.to_datetime(df['time_done'], unit='s')
print(df)

```

--------------------------------

### Read OpenCL Buffer to Matrix using CLBufferRead

Source: https://www.mql5.com/en/docs/opencl/clbufferread

Reads data from an OpenCL buffer directly into a matrix. Enables specifying the number of rows and columns to read from the buffer. Returns true if the operation is successful, false otherwise.

```MQL5
uint CLBufferRead(
int buffer, // a handle to the OpenCL buffer
uint buffer_offset, // an offset in the OpenCL buffer in bytes
const matrix& mat, // the matrix for receiving the values from the buffer
ulong rows=-1, // the number of rows in the matrix
ulong cols=-1 // the number of columns in the matrix
);
```

--------------------------------

### Checking Allowed Volume Execution Types in MQL5

Source: https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties

Explains how to check the allowed volume execution types for a financial instrument using the SymbolInfoInteger() function with the SYMBOL_FILLING_MODE property in MQL5. This helps determine which filling types are supported for a given symbol.

```MQL5
long allowed_filling_modes = SymbolInfoInteger(_Symbol, SYMBOL_FILLING_MODE);
// Check if a specific mode is allowed, e.g., ORDER_FILLING_FOK
if (allowed_filling_modes & ORDER_FILLING_FOK)
{
   // ORDER_FILLING_FOK is allowed
}
```

--------------------------------

### Set Symbol Double Property Variable (MQL5)

Source: https://www.mql5.com/en/docs/marketinformation/symbolinfodouble

Attempts to retrieve a double-precision property of a specified symbol and store it in a reference variable. This variant returns a boolean indicating success or failure. It requires the symbol name, a property identifier, and a double variable passed by reference to receive the value.

```MQL5
bool SymbolInfoDouble(
string name, // symbol
ENUM_SYMBOL_INFO_DOUBLE prop_id, // identifier of the property
double& double_var // here we accept the property value
);
```

--------------------------------

### MQL5 MqlDateTime Structure Definition

Source: https://www.mql5.com/en/docs/constants/structures/mqldatetime

Defines the MqlDateTime structure in MQL5, which holds date and time components. Each field is an integer representing a specific time unit.

```MQL5
struct MqlDateTime {
int year; // Year
int mon; // Month
int day; // Day
int hour; // Hour
int min; // Minutes
int sec; // Seconds
int day_of_week; // Day of week (0-Sunday, 1-Monday, ... ,6-Saturday)
int day_of_year; // Day number of the year (January 1st is assigned the number value of zero)
};
```

--------------------------------

### Calculate Exponential Distribution Probability Density in MQL5

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/exponential

Calculates the probability density function (PDF) of the exponential distribution for given values. It takes an array of x-values, the expected value (mu), and a boolean indicating if the result should be normalized, outputting the PDF values. Useful for plotting theoretical distribution curves.

```MQL5
#include <Math\Stat\Exponential.mqh>

void OnStart()
{
    double x_values[] = {1.0, 2.0, 3.0, 4.0, 5.0};
    double mu = 2.0;
    double y_values[];
    
    // Calculate the probability density for the given x values
    MathProbabilityDensityExponential(x_values, mu, false, y_values);
    
    // Print the results
    for(int i = 0; i < ArraySize(x_values); i++)
    {
        Print("PDF at x=", x_values[i], " is ", y_values[i]);
    }
}
```

--------------------------------

### MQL5: Math Probability Density Geometric

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/geometric

This snippet refers to the MQL5 function `MathProbabilityDensityGeometric`, used for calculating the probability density function of the geometric distribution. This is useful for analyzing discrete probability scenarios, such as the number of trials needed for a success.

```MQL5
MathProbabilityDensityGeometric
```

--------------------------------

### MQL5 Script to Retrieve Tick History

Source: https://www.mql5.com/en/docs/series/copyticks

This script demonstrates how to use the CopyTicks() and CopyTicksRange() functions in MQL5 to retrieve tick data for a specified symbol. It handles potential synchronization issues and displays information about the retrieved ticks, including timestamps and trade data. The function attempts to retrieve ticks up to 100 million and then specifically for the current day.

```MQL5
#property copyright "Copyright 2000-2024, MetaQuotes Ltd."
#property link "https://www.mql5.com"
#property version "1.00"
#property script_show_inputs
//--- Requesting 100 million ticks to be sure we receive the entire tick history
input int getticks=100000000; // The number of required ticks
//+------------------------------------------------------------------+
//| Script program start function |
//+------------------------------------------------------------------+
void OnStart()
{
//---    
int attempts=0; // Count of attempts
bool success=false; // The flag of a successful copying of ticks
MqlTick tick_array[]; // Tick receiving array
MqlTick lasttick; // To receive last tick data
SymbolInfoTick(_Symbol,lasttick);
//--- Make 3 attempts to receive ticks
while(attempts<3)
{
//--- Measuring start time before receiving the ticks
uint start=GetTickCount();
//--- Requesting the tick history since 1970.01.01 00:00.001 (parameter from=1 ms)
int received=CopyTicks(_Symbol,tick_array,COPY_TICKS_ALL,1,getticks);
if(received!=-1)
{
//--- Showing information about the number of ticks and spent time
PrintFormat("%s: received %d ticks in %d ms",_Symbol,received,GetTickCount()-start);
//--- If the tick history is synchronized, the error code is equal to zero
if(GetLastError()==0)
{
success=true;
break;
}
else
PrintFormat("%s: Ticks are not synchronized yet, %d ticks received for %d ms. Error=%d",
_Symbol,received,GetTickCount()-start,_LastError);
}
//--- Counting attempts
attempts++;
//--- A one-second pause to wait for the end of synchronization of the tick database
Sleep(1000);
}
//--- Receiving the requested ticks from the beginning of the tick history failed in three attempts
if(!success)
{
PrintFormat("Error! Failed to receive %d ticks of %s in three attempts",getticks,_Symbol);
return;
}
int ticks=ArraySize(tick_array);
//--- Showing the time of the first tick in the array
datetime firstticktime=tick_array[ticks-1].time;
PrintFormat("Last tick time = %s.%03I64u",
TimeToString(firstticktime,TIME_DATE|TIME_MINUTES|TIME_SECONDS),tick_array[ticks-1].time_msc%1000);
//--- Show the time of the last tick in the array
datetime lastticktime=tick_array[0].time;
PrintFormat("First tick time = %s.%03I64u",
TimeToString(lastticktime,TIME_DATE|TIME_MINUTES|TIME_SECONDS),tick_array[0].time_msc%1000);
  
//---    
MqlDateTime today;
datetime current_time=TimeCurrent(); 
TimeToStruct(current_time,today); 
PrintFormat("current_time=%s",TimeToString(current_time)); 
today.hour=0;
today.min=0;
today.sec=0;
datetime startday=StructToTime(today);
datetime endday=startday+24*60*60;
if((ticks=CopyTicksRange(_Symbol,tick_array,COPY_TICKS_ALL,startday*1000,endday*1000))==-1)    
{
PrintFormat("CopyTicksRange(%s,tick_array,COPY_TICKS_ALL,%s,%s) failed, error %d",    
_Symbol,TimeToString(startday),TimeToString(endday),GetLastError());    
return;    
}
ticks=MathMax(100,ticks);
//--- Showing the first 100 ticks of the last day
int counter=0;
for(int i=0;i<ticks;i++)
{
datetime time=tick_array[i].time;
if((time>=startday) && (time<endday) && counter<100)
{
counter++;
PrintFormat("%d. %s",counter,GetTickDescription(tick_array[i]));
}
}
//--- Showing the first 100 deals of the last day
counter=0;
for(int i=0;i<ticks;i++)
{
datetime time=tick_array[i].time;
if((time>=startday) && (time<endday) && counter<100)
{
if(((tick_array[i].flags&TICK_FLAG_BUY)==TICK_FLAG_BUY) || ((tick_array[i].flags&TICK_FLAG_SELL)==TICK_FLAG_SELL))
{
counter++;
PrintFormat("%d. %s",counter,GetTickDescription(tick_array[i]));
}
}
}
}

```

--------------------------------

### Shut Down MetaTrader 5 Terminal Connection

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5marketbookget_py

This function terminates the connection to the MetaTrader 5 terminal. It is essential for gracefully closing the application's interface with the trading platform. Ensure all operations are completed before calling this function.

```python
import MetaTrader5 as mt5

# shut down connection to the MetaTrader 5 terminal
mt5.shutdown()
```

--------------------------------

### Retrieve and Modify Open Position SL/TP in MQL5

Source: https://www.mql5.com/en/docs/constants/tradingconstants/enum_trade_request_actions

This code retrieves details of an open position, including its magic number, volume, Stop Loss, and Take Profit. If the magic number matches a predefined expert magic number and SL/TP are not set, it calculates new SL/TP levels based on current market prices (bid/ask), symbol properties (stops level, point), and desired offsets. It then prepares and sends a TRADE_ACTION_SLTP trade request to modify the position's Stop Loss and Take Profit.

```mql5
ulong magic=PositionGetInteger(POSITION_MAGIC); // MagicNumber of the position  
double volume=PositionGetDouble(POSITION_VOLUME); // volume of the position  
double sl=PositionGetDouble(POSITION_SL); // Stop Loss of the position  
double tp=PositionGetDouble(POSITION_TP); // Take Profit of the position  
ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE); // type of the position  
//--- output information about the position  
PrintFormat("#%I64u %s %s %.2f %s sl: %s tp: %s [%I64d]",  
position_ticket,  
position_symbol,  
EnumToString(type),  
volume,  
DoubleToString(PositionGetDouble(POSITION_PRICE_OPEN),digits),  
DoubleToString(sl,digits),  
DoubleToString(tp,digits),  
magic);
//--- if the MagicNumber matches, Stop Loss and Take Profit are not defined  
if(magic==EXPERT_MAGIC && sl==0 && tp==0)  
{
//--- calculate the current price levels  
double price=PositionGetDouble(POSITION_PRICE_OPEN);
double bid=SymbolInfoDouble(position_symbol,SYMBOL_BID);
double ask=SymbolInfoDouble(position_symbol,SYMBOL_ASK);
int stop_level=(int)SymbolInfoInteger(position_symbol,SYMBOL_TRADE_STOPS_LEVEL);
double price_level;
//--- if the minimum allowed offset distance in points from the current close price is not set  
if(stop_level<=0)
stop_level=150; // set the offset distance of 150 points from the current close price  
else
stop_level+=50; // set the offset distance to (SYMBOL_TRADE_STOPS_LEVEL + 50) points for reliability  

//--- calculation and rounding of the Stop Loss and Take Profit values  
price_level=stop_level*SymbolInfoDouble(position_symbol,SYMBOL_POINT);
if(type==POSITION_TYPE_BUY)
{
sl=NormalizeDouble(bid-price_level,digits);
tp=NormalizeDouble(ask+price_level,digits);
}
else
{
sl=NormalizeDouble(ask+price_level,digits);
tp=NormalizeDouble(bid-price_level,digits);
}
//--- zeroing the request and result values  
ZeroMemory(request);
ZeroMemory(result);
//--- setting the operation parameters  
request.action =TRADE_ACTION_SLTP; // type of trade operation  
request.position=position_ticket; // ticket of the position  
request.symbol=position_symbol; // symbol   
request.sl =sl; // Stop Loss of the position  
request.tp =tp; // Take Profit of the position  
request.magic=EXPERT_MAGIC; // MagicNumber of the position  
//--- output information about the modification  
PrintFormat("Modify #%I64d %s %s",position_ticket,position_symbol,EnumToString(type));  
//--- send the request  
if(!OrderSend(request,result))
PrintFormat("OrderSend error %d",GetLastError()); // if unable to send the request, output the error code  
//--- information about the operation   
PrintFormat("retcode=%u deal=%I64u order=%I64u",result.retcode,result.deal,result.order);
}
}
}
```

--------------------------------

### MQL5: Retrieve Calendar Event Values (Method 3)

Source: https://www.mql5.com/en/docs/constants/structures/mqlcalendar

This MQL5 code snippet demonstrates the third method for retrieving calendar event values without explicit checks. It populates an array of adjusted values by directly accessing the 'revision', 'impact_type', 'actual_value', 'prev_value', 'revised_prev_value', and 'forecast_value' from the source 'values' array. The retrieved data is then printed to the console.

```mql5
values_adjusted_3[i].revision=values[i].revision;
values_adjusted_3[i].impact_type=values[i].impact_type;
//--- get values without checks
values_adjusted_3[i].actual_value=values[i].GetActualValue();
values_adjusted_3[i].prev_value=values[i].GetPreviousValue();
values_adjusted_3[i].revised_prev_value=values[i].GetRevisedValue();
values_adjusted_3[i].forecast_value=values[i].GetForecastValue();
}
Print("The third method to get calendar values - without checks");
ArrayPrint(values_adjusted_3);
}
```

--------------------------------

### MQL5 OpenCL Resource Cleanup Function

Source: https://www.mql5.com/en/docs/opencl/clbufferread

This MQL5 function is responsible for freeing allocated OpenCL memory, kernel, program, and context resources. It ensures proper cleanup to prevent memory leaks. It takes OpenCL object identifiers as input.

```mql5
void CLFreeAll(const int clMem, const int clKrn, const int clPrg, const int clCtx)   
{
CLBufferFree(clMem);   
CLKernelFree(clKrn);   
CLProgramFree(clPrg);   
CLContextFree(clCtx);
}
```

--------------------------------

### MQL5: Close All Positions by Magic Number

Source: https://www.mql5.com/en/docs/constants/structures/mqltraderequest

This MQL5 code snippet iterates through all open positions and closes those matching a specific MagicNumber. It retrieves position details like ticket, symbol, volume, and type, then constructs a closing trade request (ORDER_TYPE_SELL for buy positions, ORDER_TYPE_BUY for sell positions) using TRADE_ACTION_DEAL.

```MQL5
#define EXPERT_MAGIC 123456 // MagicNumber of the expert  
//+------------------------------------------------------------------+  
//| Closing all positions |  
//+------------------------------------------------------------------+  
void OnStart()  
{  
//--- declare and initialize the trade request and result of trade request  
MqlTradeRequest request;  
MqlTradeResult result;  
int total=PositionsTotal(); // number of open positions   
//--- iterate over all open positions  
for(int i=total-1; i>=0; i--)  
{  
//--- parameters of the order  
ulong position_ticket=PositionGetTicket(i); // ticket of the position  
string position_symbol=PositionGetString(POSITION_SYMBOL); // symbol   
int digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS); // number of decimal places  
ulong magic=PositionGetInteger(POSITION_MAGIC); // MagicNumber of the position  
double volume=PositionGetDouble(POSITION_VOLUME); // volume of the position  
ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE); // type of the position  
//--- output information about the position  
PrintFormat("#%I64u %s %s %.2f %s [%I64d]",  
position_ticket,  
position_symbol,  
EnumToString(type),  
volume,  
DoubleToString(PositionGetDouble(POSITION_PRICE_OPEN),digits),  
magic);  
//--- if the MagicNumber matches  
if(magic==EXPERT_MAGIC)  
{  
//--- zeroing the request and result values  
ZeroMemory(request);  
ZeroMemory(result);  
//--- setting the operation parameters  
request.action =TRADE_ACTION_DEAL; // type of trade operation  
request.position =position_ticket; // ticket of the position  
request.symbol =position_symbol; // symbol   
request.volume =volume; // volume of the position  
request.deviation=5; // allowed deviation from the price  
request.magic =EXPERT_MAGIC; // MagicNumber of the position  
//--- set the price and order type depending on the position type  
if(type==POSITION_TYPE_BUY)  
{  
request.price=SymbolInfoDouble(position_symbol,SYMBOL_BID);  
request.type =ORDER_TYPE_SELL;  
}  
else  
{  
request.price=SymbolInfoDouble(position_symbol,SYMBOL_ASK);  
request.type =ORDER_TYPE_BUY;  
}  
//--- output information about the closure  
PrintFormat("Close #%I64d %s %s",position_ticket,position_symbol,EnumToString(type));  
//--- send the request  

```

--------------------------------

### Shutdown MetaTrader 5 Connection

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5historydealsget_py

This is a utility snippet to properly close the connection to the MetaTrader 5 terminal. It is essential for releasing resources and ensuring a clean exit from the application. This function should typically be called after all data retrieval and operations are completed.

```python
# shut down connection to the MetaTrader 5 terminal
mt5.shutdown()
```

--------------------------------

### Set DirectX Buffer Data

Source: https://www.mql5.com/en/docs/directx/dxcontextcreate

Sets the data for a buffer (vertex or index buffer). This function updates the contents of a buffer with new data. Requires a valid context handle and buffer handle.

```MQL5
void DXBufferSet(
  int context_handle, // handle of the graphic context
  int buffer_handle,  // handle of the buffer to update
  uint offset,        // offset in bytes from the start of the buffer
  uchar &data[]       // array containing the new buffer data
);

```

--------------------------------

### Fetch Historical Orders by Date Range and Symbol Group in Python

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5historyordersget_py

Retrieves historical orders within a specified date range and filters them by a symbol group. This function requires the `MetaTrader5` and `pandas` libraries. It connects to the MetaTrader 5 terminal, retrieves order data, and prints the count or an error message.

```python
from datetime import datetime
import MetaTrader5 as mt5
import pandas as pd

pd.set_option('display.max_columns', 500) # number of columns to be displayed
pd.set_option('display.width', 1500) # max table width to display

# display data on the MetaTrader 5 package
print("MetaTrader5 package author: ",mt5.__author__)
print("MetaTrader5 package version: ",mt5.__version__)
print()

# establish connection to the MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed, error code =",mt5.last_error())
    quit()

# get the number of orders in history
from_date=datetime(2020,1,1)
to_date=datetime.now()
history_orders=mt5.history_orders_get(from_date, to_date, group="*GBP*")
if history_orders==None:
    print("No history orders with group=\" *GBP* \", error code={}".format(mt5.last_error()))
elif len(history_orders)>0:
    print("history_orders_get({}, {}, group=\" *GBP* \")={}".format(from_date,to_date,len(history_orders)))
print()
```

--------------------------------

### MQL5: Calculate Logistic Distribution Density and Cumulative Probability

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/logistic

This snippet demonstrates how to calculate the probability density function (PDF) and cumulative distribution function (CDF) for the logistic distribution using MQL5. It utilizes MathProbabilityDensityLogistic and MathCumulativeDistributionLogistic functions. The input includes the random variable value, mean (mu_par), and scale (sigma_par) parameters.

```MQL5
#include <Math\Stat\Logistic.mqh>
#include <Math\Stat\Math.mqh>

void OnStart()
{
  double mu_par = 6.0;
  double sigma_par = 2.0;
  double x_value = 7.0;
  double density, cumulative;

  // Calculate PDF
  MathProbabilityDensityLogistic(x_value, mu_par, sigma_par, false, density);
  Print("Probability Density at ", x_value, ": ", density);

  // Calculate CDF
  MathCumulativeDistributionLogistic(x_value, mu_par, sigma_par, false, cumulative);
  Print("Cumulative Distribution at ", x_value, ": ", cumulative);
}

```

--------------------------------

### Check Allowed Filling Mode in MQL5

Source: https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants

This MQL5 function checks if a specific filling mode is allowed for a given financial symbol. It retrieves the symbol's filling mode property using SymbolInfoInteger() and performs a bitwise AND operation to verify the presence of the desired fill type.

```MQL5
//+------------------------------------------------------------------+
//| check if a given filling mode is allowed |
//+------------------------------------------------------------------+
bool IsFillingTypeAllowed(string symbol,int fill_type)
{
//--- get the value of the property describing the filling mode
int filling=(int)SymbolInfoInteger(symbol,SYMBOL_FILLING_MODE);
//--- return 'true' if the fill_type mode is allowed
return((filling&fill_type)==fill_type);
}
```

--------------------------------

### Write to OpenCL Buffer from Array - MQL5

Source: https://www.mql5.com/en/docs/opencl/clbufferwrite

Writes data from a MQL5 array into an OpenCL buffer. Allows specifying offsets within the buffer and the array, as well as the number of elements to write. Returns the count of successfully written elements. Errors can be checked with GetLastError().

```mql5
uint CLBufferWrite(
int buffer, // A handle to the OpenCL buffer
const void& data[], // An array of values
uint buffer_offset = 0, // An offset in the OpenCL buffer in bytes, 0 by default
uint data_offset = 0, // An offset in the array in elements, 0 by default
uint data_count = WHOLE_ARRAY // The number of values from the array for writing, the whole array by default
);
```

--------------------------------

### MQL5 OnCalculate for Bollinger Bands Indicator

Source: https://www.mql5.com/en/docs/indicators/ibands

The OnCalculate function handles the iterative calculation of the indicator. It determines the number of values to copy from the iBands indicator and fills the indicator buffers. Returns the number of bars calculated.

```mql5
//+------------------------------------------------------------------+   
//| Custom indicator iteration function |   
//+------------------------------------------------------------------+   
int OnCalculate(const int rates_total,   
const int prev_calculated,   
const datetime &time[],   
const double &open[],   
const double &high[],   
const double &low[],   
const double &close[],   
const long &tick_volume[],   
const long &volume[],   
const int &spread[])   
{   
//--- number of values copied from the iBands indicator   
int values_to_copy;   
//--- determine the number of values calculated in the indicator   
int calculated=BarsCalculated(handle);   
if(calculated<=0)   
{   
PrintFormat("BarsCalculated() returned %d, error code %d",calculated,GetLastError());   
return(0);   
}   
//--- if it is the first start of calculation of the indicator or if the number of values in the iBands indicator changed   
//---or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history)   
if(prev_calculated==0 || calculated!=bars_calculated || rates_total>prev_calculated+1)   
{   
//--- if the size of indicator buffers is greater than the number of values in the iBands indicator for symbol/period, then we don't copy everything    
//--- otherwise, we copy less than the size of indicator buffers   
if(calculated>rates_total) values_to_copy=rates_total;   
else values_to_copy=calculated;   
}   
else   
{   
//--- it means that it's not the first time of the indicator calculation, and since the last call of OnCalculate()   
//--- for calculation not more than one bar is added   
values_to_copy=(rates_total-prev_calculated)+1;   
}   
//--- fill the array with values of the Bollinger Bands indicator   
//--- if FillArraysFromBuffer returns false, it means the information is nor ready yet, quit operation   
if(!FillArraysFromBuffers(MiddleBuffer,UpperBuffer,LowerBuffer,bands_shift,handle,values_to_copy)) return(0);   
//--- form the message   
string comm=StringFormat("%s ==> Updated value in the indicator %s: %d",   
TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),   
short_name,   
values_to_copy);   
//--- display the service message on the chart   
Comment(comm);   
//--- memorize the number of values in the Bollinger Bands indicator   
bars_calculated=calculated;   
//--- return the prev_calculated value for the next call   
return(rates_total);   
}
```

--------------------------------

### MQL5 DXDraw Function for Rendering Vertices

Source: https://www.mql5.com/en/docs/directx/dxdraw

The DXDraw function in MQL5 renders a specified range of vertices from a vertex buffer previously set using DXBufferSet. It requires a valid graphic context handle. Shaders must be set using DXShaderSet before calling DXDraw.

```MQL5
bool DXDraw(
int context, // graphic context handle    
uint start=0, // first vertex index   
uint count=WHOLE_ARRAY // number of vertices   
);
```

--------------------------------

### order_send Function

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5ordersend_py

This function sends a request to perform a trading operation from the terminal to the trade server. It is similar to the OrderSend function in MQL5.

```APIDOC
## POST /order_send

### Description
Sends a trading request to the trade server, similar to the MQL5 OrderSend function.

### Method
POST

### Endpoint
/order_send

### Parameters
#### Request Body
- **request** (MqlTradeRequest) - Required - A structure describing the trading action to be performed.

### Request Example
```json
{
  "request": {
    "action": "TRADE_ACTION_DEAL",
    "magic": 12345,
    "order": 0,
    "symbol": "USDJPY",
    "volume": 0.1,
    "price": 100.50,
    "stoplimit": 0.0,
    "sl": 0.0,
    "tp": 0.0,
    "deviation": 10,
    "type": "ORDER_TYPE_BUY",
    "type_filling": "ORDER_TYPE_FILLING_IOC",
    "type_time": "ORDER_TYPE_TIME_GTC",
    "expiration": 0,
    "comment": "My Buy Order",
    "position": 0,
    "position_by": 0
  }
}
```

### Response
#### Success Response (200)
- **retcode** (int) - Execution result code.
- **deal** (int) - Deal ticket.
- **order** (int) - Order ticket.
- **message** (string) - Description of the execution result.
- **request** (MqlTradeRequest) - The request structure passed to order_send().

#### Response Example
```json
{
  "retcode": 1,
  "deal": 123456789,
  "order": 987654321,
  "message": "Request executed successfully",
  "request": {
    "action": "TRADE_ACTION_DEAL",
    "magic": 12345,
    "order": 0,
    "symbol": "USDJPY",
    "volume": 0.1,
    "price": 100.50,
    "stoplimit": 0.0,
    "sl": 0.0,
    "tp": 0.0,
    "deviation": 10,
    "type": "ORDER_TYPE_BUY",
    "type_filling": "ORDER_TYPE_FILLING_IOC",
    "type_time": "ORDER_TYPE_TIME_GTC",
    "expiration": 0,
    "comment": "My Buy Order",
    "position": 0,
    "position_by": 0
  }
}
```

### Error Handling
- Information on errors can be obtained using the `last_error()` function.
```

--------------------------------

### MQL5: Normalize Max/Min and Step Values

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/geometric

This MQL5 function normalizes maximum, minimum, and step values based on the range of the sequence. It calculates the appropriate degree of precision for normalization and adjusts the step value accordingly. This is useful for ensuring consistent data scaling in trading strategies.

```MQL5
void GetMaxMinStepValues(double &maxv,double &minv,double &stepv)   
{
//--- calculate the absolute range of the sequence to obtain the precision of normalization   
double range=MathAbs(maxv-minv);   
int degree=(int)MathRound(MathLog10(range));   
//--- normalize the maximum and minimum values to the specified precision   
maxv=NormalizeDouble(maxv,degree);   
minv=NormalizeDouble(minv,degree);   
//--- sequence generation step is also set based on the specified precision   
stepv=NormalizeDouble(MathPow(10,-degree),degree);   
if((maxv-minv)/stepv<10)   
stepv/=10.;   
}
```

--------------------------------

### Broadcast Event to All Open Charts in MQL5

Source: https://www.mql5.com/en/docs/eventfunctions/eventchartcustom

Iterates through all open charts in the MetaTrader 5 terminal and sends a custom chart event to each. This function allows for inter-chart communication.

```MQL5
void BroadcastEvent(long lparam,double dparam,string sparam)
{
int eventID=broadcastEventID-CHARTEVENT_CUSTOM;
long currChart=ChartFirst();
int i=0;
while(i<CHARTS_MAX) // We have certainly no more than CHARTS_MAX open charts
{
EventChartCustom(currChart,eventID,lparam,dparam,sparam);
currChart=ChartNext(currChart); // We have received a new chart from the previous
if(currChart==-1) break; // Reached the end of the charts list
i++;// Do not forget to increase the counter
}
}
```

--------------------------------

### MQL5: Noncentral t-distribution statistical calculations and random data generation

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/noncentralstudent

This MQL5 script demonstrates how to use functions from the NoncentralT.mqh library to generate a sample from the noncentral t-distribution, plot its histogram, and compare it with the theoretical distribution density. It requires the Graphic.mqh and Math.mqh libraries. The script takes degrees of freedom (nu) and noncentrality parameter (delta) as inputs.

```mql5
#include <Graphics\Graphic.mqh>
#include <Math\Stat\NoncentralT.mqh>
#include <Math\Stat\Math.mqh>

#property script_show_inputs

//--- input parameters
input double nu_par=30; // the number of degrees of freedom
input double delta_par=5; // noncentrality parameter

//+------------------------------------------------------------------+
//| Script program start function |
//+------------------------------------------------------------------+
void OnStart()
{
//--- hide the price chart
ChartSetInteger(0,CHART_SHOW,false);

//--- initialize the random number generator 
MathSrand(GetTickCount());

//--- generate a sample of the random variable
long chart=0;
string name="GraphicNormal";
int n=1000000; // the number of values in the sample
int ncells=51; // the number of intervals in the histogram
double x[]; // centers of the histogram intervals
double y[]; // the number of values from the sample falling within the interval
double data[]; // sample of random values
double max,min; // the maximum and minimum values in the sample

//--- obtain a sample from the noncentral Student's t-distribution
MathRandomNoncentralT(nu_par,delta_par,n,data);

//--- calculate the data to plot the histogram
CalculateHistogramArray(data,x,y,max,min,ncells);

//--- obtain the sequence boundaries and the step for plotting the theoretical curve
double step;
GetMaxMinStepValues(max,min,step);
step=MathMin(step,(max-min)/ncells);

//--- obtain the theoretically calculated data at the interval of [min,max]
double x2[];
double y2[];
MathSequence(min,max,step,x2);
MathProbabilityDensityNoncentralT(x2,nu_par,delta_par,false,y2);

//--- set the scale
double theor_max=y2[ArrayMaximum(y2)];
double sample_max=y[ArrayMaximum(y)];
double k=sample_max/theor_max;
for(int i=0; i<ncells; i++)
 y[i]/=k;

//--- output charts
CGraphic graphic;
if(ObjectFind(chart,name)<0)
 graphic.Create(chart,name,0,0,0,780,380);
else
 graphic.Attach(chart,name);

graphic.BackgroundMain(StringFormat("Noncentral t-distribution nu=%G delta=%G",nu_par,delta_par));
graphic.BackgroundMainSize(16);

//--- plot all curves
graphic.CurveAdd(x,y,CURVE_HISTOGRAM,"Sample").HistogramWidth(6);

//--- and now plot the theoretical curve of the distribution density
graphic.CurveAdd(x2,y2,CURVE_LINES,"Theory");
graphic.CurvePlotAll();

//--- plot all curves
graphic.Update();
}

//+------------------------------------------------------------------+
//| Calculate frequencies for data set |
//+------------------------------------------------------------------+
bool CalculateHistogramArray(const double &data[],double &intervals[],double &frequency[],
 double &maxv,double &minv,const int cells=10)
{
if(cells<=1) return (false);

int size=ArraySize(data);
if(size<cells*10) return (false);

minv=data[ArrayMinimum(data)];
maxv=data[ArrayMaximum(data)];

double range=maxv-minv;
double width=range/cells;
if(width==0) return false;

ArrayResize(intervals,cells);
ArrayResize(frequency,cells);

//--- define the interval centers
for(int i=0; i<cells; i++)
{
 intervals[i]=minv+(i+0.5)*width;
 frequency[i]=0;
}

//--- fill the frequencies of falling within the interval
for(int i=0; i<size; i++)
{
 int ind=int((data[i]-minv)/width);
 if(ind>=cells) ind=cells-1;
 frequency[ind]++;
}

return (true);
}

//+------------------------------------------------------------------+
//| Calculates values for sequence generation |
//+------------------------------------------------------------------+
```

--------------------------------

### Calculate Beta Distribution Quantile (MQL5)

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/beta

Calculates the inverse beta distribution function, also known as the quantile function. Given a probability, it returns the value of the random variable below which that probability falls. It requires the probability and the distribution's shape parameters (alpha and beta).

```MQL5
#include <Math\Stat\Beta.mqh>

// Example usage (assuming alpha, beta, and probability are defined):
// double alpha = 2.0;
// double beta = 5.0;
// double probability = 0.95;
// double quantile_value = MathQuantileBeta(probability, alpha, beta);

```

--------------------------------

### Fill Indicator Buffers from iBands in MQL5

Source: https://www.mql5.com/en/docs/indicators/ibands

This function copies data from the iBands indicator buffers into the provided arrays (MiddleBuffer, UpperBuffer, LowerBuffer). It handles potential copying errors and returns true on success, false otherwise.

```mql5
//+------------------------------------------------------------------+   
//| Filling indicator buffers from the iBands indicator |   
//+------------------------------------------------------------------+   
bool FillArraysFromBuffers(double &base_values[], // indicator buffer of the middle line of Bollinger Bands   
double &upper_values[], // indicator buffer of the upper border   
double &lower_values[], // indicator buffer of the lower border   
int shift, // shift   
int ind_handle, // handle of the iBands indicator   
int amount // number of copied values   
)   
{   
//--- reset error code   
ResetLastError();   
//--- fill a part of the MiddleBuffer array with values from the indicator buffer that has 0 index   
if(CopyBuffer(ind_handle,0,-shift,amount,base_values)<0)   
{   
//--- if the copying fails, tell the error code   
PrintFormat("Failed to copy data from the iBands indicator, error code %d",GetLastError());   
//--- quit with zero result - it means that the indicator is considered as not calculated   
return(false);   
}   
  
}
```

--------------------------------

### MQL5 OnTrade Event Function

Source: https://www.mql5.com/en/docs/basis/function/events

The OnTrade() function is called when a Trade event occurs, which signifies changes in orders, positions, or deals. It is used to handle trade-related activities and requires manual implementation of trade account state verification.

```MQL5
void OnTrade();
```

--------------------------------

### Send Trade Request and Handle Errors (MQL5)

Source: https://www.mql5.com/en/docs/constants/structures/mqltraderequest

This snippet demonstrates sending a trade request using OrderSend and handling potential errors. If OrderSend fails, it prints the error code obtained from GetLastError(). It then prints the result of the operation, including retcode, deal, and order identifiers. Finally, it resets the request and result structures using ZeroMemory.

```MQL5
//--- send the request
if(!OrderSend(request,result))
PrintFormat("OrderSend error %d",GetLastError()); // if unable to send the request, output the error code
//--- information about the operation
PrintFormat("retcode=%u deal=%I64u order=%I64u",result.retcode,result.deal,result.order);
//--- zeroing the request and result values
ZeroMemory(request);
ZeroMemory(result);
```

--------------------------------

### MQL5 Trade Execution Modes

Source: https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties

Defines the trade execution modes for financial instruments. These values are used in MQL5 to specify how trade orders should be executed.

```MQL5
enum ENUM_SYMBOL_TRADE_EXECUTION
{
   SYMBOL_TRADE_EXECUTION_REQUEST,
   SYMBOL_TRADE_EXECUTION_INSTANT,
   SYMBOL_TRADE_EXECUTION_MARKET,
   SYMBOL_TRADE_EXECUTION_EXCHANGE
};
```

--------------------------------

### MQL5 Helper Function: CalculateHistogramArray

Source: https://www.mql5.com/en/docs/standardlibrary/mathematics/stat/exponential

A helper function to calculate histogram data from a set of sample data. It determines the minimum and maximum values, calculates interval widths, and counts the frequency of data points falling into each interval. This is typically used for visualizing data distributions.

```MQL5
bool CalculateHistogramArray(const double &data[], double &intervals[], double &frequency[],
                         double &maxv, double &minv, const int cells = 10)
{
    if (cells <= 1) return (false);
    int size = ArraySize(data);
    if (size < cells * 10) return (false);
    
    minv = data[ArrayMinimum(data)];
    maxv = data[ArrayMaximum(data)];
    double range = maxv - minv;
    double width = range / cells;
    if (width == 0) return false;
    
    ArrayResize(intervals, cells);
    ArrayResize(frequency, cells);
    
    // define the interval centers
    for (int i = 0; i < cells; i++)
    {
        intervals[i] = minv + i * width;
        frequency[i] = 0;
    }
    
    // fill the frequencies of falling within the interval
    for (int i = 0; i < size; i++)
    {
        int ind = int((data[i] - minv) / width);
        if (ind >= cells) ind = cells - 1;
        frequency[ind]++;
    }
    return (true);
}
```

--------------------------------

### Set DirectX Shader in MQL5

Source: https://www.mql5.com/en/docs/directx/dxshaderset

The DXShaderSet function is used to set a specific shader handle within a given DirectX graphics context. This is crucial for defining how graphical elements are processed and rendered. It returns a boolean indicating success or failure, with GetLastError() available for error details. Multiple shader types can be active.

```MQL5
bool DXShaderSet(
int context, // graphic context handle
int shader // shader handle
);
```

--------------------------------

### MQL5 CopyTicks Function Signature

Source: https://www.mql5.com/en/docs/series/copyticks

The function signature for CopyTicks in MQL5. It defines the parameters for specifying the symbol, an array to store ticks, flags for filtering, and a time range for tick retrieval.

```mql5
int CopyTicks(
  string symbol_name,      // Symbol name
  MqlTick& ticks_array[],  // Tick receiving array
  uint flags=COPY_TICKS_ALL, // The flag that determines the type of received ticks
  ulong from=0,            // The date from which you want to request ticks
  uint count=0             // The number of ticks that you want to receive
);
```

--------------------------------

### Shutdown MQL5 Connection with Python

Source: https://www.mql5.com/en/docs/python_metatrader5/mt5shutdown_py

Closes the established connection to the MetaTrader 5 terminal using the Python integration library. This function does not return any value. It's typically called after operations are completed to free up resources.

```python
import MetaTrader5 as mt5

# establish connection to the MetaTrader 5 terminal
if not mt5.initialize():
    print("initialize() failed")
    quit()

# shut down connection to the MetaTrader 5 terminal
mt5.shutdown()
```