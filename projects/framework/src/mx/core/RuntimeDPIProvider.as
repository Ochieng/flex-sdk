package mx.core
{
import flash.system.Capabilities;

/**
 *  The RuntimeDPIProvider class provides the default mapping of
 *  similar device DPI values into predefined DPI classes.
 *  An Application may have its runtimeDPIProvider property set to a
 *  subclass of RuntimeDPIProvider to override Flex's default mappings.
 *  Overriding Flex's default mappings will cause changes in the Application's
 *  automatic scaling behavior.
 * 
 *  <p>Overriding Flex's default mappings is usually only necessary for devices
 *  that incorrectly report their screenDPI and for devices that may scale better
 *  in a different DPI class.</p>
 * 
 *  <p>Flex's default mappings are:
 *     <table class="innertable">
 *        <tr><td>160 DPI</td><td>&lt;200 DPI</td></tr>
 *        <tr><td>240 DPI</td><td>&gt;=200 DPI and &lt;280 DPI</td></tr>
 *        <tr><td>320 DPI</td><td>&gt;=280 DPI</td></tr>
 *     </table>
 *  </p>
 * 
 *  <p>Subclasses of RuntimeDPIProvider should only depend on runtime APIs
 *  and should not depend on any classes specific to the Flex framework except
 *  <code>mx.core.DPIClassification</code>.</p>
 * 
 *  @see mx.core.DPIClassification
 *  @see spark.components.Application#applicationDPI
 */
public class RuntimeDPIProvider
{
    /**
     *  Constructor.
     */
    public function RuntimeDPIProvider()
    {
    }
    
    /**
     *  Returns the runtime DPI of the current device by mapping its
     *  <code>flash.system.Capabilities.screenDPI</code> to one of several DPI
     *  values in <code>mx.core.DPIClassification</code>.
     * 
     *  A number of devices can have slightly different DPI values and Flex maps these
     *  into the several DPI classes.
     * 
     *  Flex uses this method to calculate the current DPI value when an Application
     *  authored for a specific DPI is adapted to the current one through scaling.
     * 
     *  @param dpi The DPI value.
     *  @return The corresponding <code>DPIClassification</code> value.
     *  
     *  @see flash.system.Capabilities
     *  @see mx.core.DPIClassification
     */
    public function get runtimeDPI():Number
    {
        var dpi:Number = Capabilities.screenDPI;
        
        if (dpi < 200)
            return DPIClassification.DPI_160;
        
        if (dpi <= 280)
            return DPIClassification.DPI_240;
        
        return DPIClassification.DPI_320; 
    }
}
}