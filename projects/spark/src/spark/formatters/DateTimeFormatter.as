////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.formatters
{

import flash.globalization.DateTimeFormatter;
import flash.globalization.DateTimeNameStyle;
import flash.globalization.DateTimeStyle;

import mx.core.mx_internal;
import mx.formatters.IFormatter;

import spark.globalization.LastOperationStatus;
import spark.globalization.supportClasses.GlobalizationBase;

use namespace mx_internal;

/**
 *  The <code>DateTimeFormatter</code> class provides locale-sensitve
 *  formatting for a <code>Date</code> object.
 *
 *  <p>This class is a wrapper class around the
 *  <code>flash.globalization.DateTimeFormatter</code>.
 *  Therefore the locale-specific formatting functionality and the month
 *  names, day names and the first day of the week are provided by the
 *  <code>flash.globalization.DateTimeFormatter</code>.
 *  However this DateTimeFormatter class can be used in MXML declartions,
 *  uses the locale style for the requested Locale ID name, and has methods
 *  and properties that are bindable.
 *  Additionally events are generated if there is an error or warning
 *  generated by the flash.globalization class.</p>
 *
 *  <p>The <code>flash.globalization.DateTimeFormatter</code> class use the
 *  underlying operating system for the formatting functionality and to
 *  supply the locale-specific data.
 *  On some operating systems, the <code>flash.globalization</code> classes
 *  are unsupported, this wrapper class provides a fallback functionality in
 *  this case.</p>
 *
 *  @see flash.globalization.DateTimeFormatter
 */
public class DateTimeFormatter extends GlobalizationBase implements IFormatter
{
    //--------------------------------------------------------------------------
    //
    //  Class Constants
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private static const DATE_STYLE:String = "dateStyle";
    private static const TIME_STYLE:String = "timeStyle";
    private static const DATE_TIME_PATTERN:String = "dateTimePattern";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructs a new <code>DateTimeFormatter</code> object to format
     *  dates and times according to the conventions of the specified locale
     *  and the provided date and time formatting styles.
     *
     *  Date and time styles are used to set date and time formatting
     *  patterns to predefined, locale dependent patterns from the operating
     *  system.
     *
     *  <p>This constructor will determine if the current operating system
     *  supports the requested locale ID name.
     *  If it is not supported then a fallback locale will be used instead.
     *  The name of the fallback locale ID can be determined from the
     *  <code>actualLocaleIDName</code> property.</p>
     *
     *  <p>To format based on the user's current operating system
     *  preferences, pass the value <code>LocaleID.DEFAULT</code> in the
     *  <code>locale</code> parameter to the constructor.</p>
     *
     *  <p>The constructor will dispatch a
     *  <code>GlobalizationStatusEvent.LAST_OPERATION_STATUS</code> event in
     *  cases where the <code>flash.globalization.DateTimeFormatter</code>
     *  class set the <code>LastOperationStatus</code> property to something
     *  other than <code>LastOperationStatus.NO_ERROR</code>.
     *  For example if the locale, dateStyle, or timeStyle result in the use
     *  of a fallback being used, the
     *  <code>GlobalizationStatusEvent.LAST_OPERATION_STATUS</code> event
     *  will be dispatched.</p>
     *
     *  @param locale The preferred locale ID name to use when determining
     *         date or time formats.
     *  @param dateStyle Specifies the style to use when formatting dates.
     *         The value should correspond to one of the values enumerated
     *         by the <code>DateTimeStyle</code> class:
     *         <ul>
     *             <li><code>DateTimeStyle.LONG</code> </li>
     *             <li><code>DateTimeStyle.MEDIUM</code></li>
     *             <li><code>DateTimeStyle.SHORT</code> </li>
     *             <li><code>DateTimeStyle.NONE</code> </li>
     *         </ul>
     *  @param timeStyle Specifies the style to use when formatting times.
     *         The value should correspond to one of the values enumerated
     *         by the <code>DateTimeStyle</code> class:
     *         <ul>
     *             <li><code>DateTimeStyle.LONG</code> </li>
     *             <li><code>DateTimeStyle.MEDIUM</code></li>
     *             <li><code>DateTimeStyle.SHORT</code> </li>
     *             <li><code>DateTimeStyle.NONE</code> </li>
     *         </ul>
     *
     *  @throws ArgumentError if the <code>dateStyle</code> or
     *          <code>timeStyle</code> parameter is not a valid
     *          <code>DateTimeStyle</code> constant.
     *  @throws TypeError if the <code>locale</code>, <code>dateStyle</code>
     *          or <code>timeStyle</code> parameter is null.
     *
     *  @see #locale
     *  @see #actualLocaleIDName
     *  @see #dateStyle
     *  @see #timeStyle
     *  @see #dateTimePattern
     *  @see spark.events.GlobalizationStatusEvent.LAST_OPERATION_STATUS
     *
     *  @playerversion Flash 10.1
     *  @langversion 3.0
     *  @productversion Flex 4.5
     *  @productversion Flash CS5
     */
    public function DateTimeFormatter()
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private var timeStyleOverride:String = DateTimeStyle.LONG;

    /**
     *  @private
     */
    private var dateStyleOverride:String = DateTimeStyle.LONG;

    /**
     *  @private
     */
    private var dateTimePatternOverride:String = null;

    /**
     *  @private
     */
    private var g11nWorkingInstance:flash.globalization.DateTimeFormatter
                                                                        = null;
    private var fallbackFormatter:FallbackDateTimeFormatter = null;

    //--------------------------------------------------------------------------
    //
    //  Overridden Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  actualLocaleIDName
    //----------------------------------

    [Bindable("change")]

    /**
     *  @inheritDoc
     *
     *  @see flash.globalization.DateTimeFormatter.actualLocaleIDName
     *  @see #DateTimeFormatter()
     *
     *  @playerversion Flash 10.1
     *  @langversion 3.0
     *  @productversion Flash CS5
     *  @productversion Flex 4.5
     */
    override public function get actualLocaleIDName():String
    {
        if (g11nWorkingInstance)
            return g11nWorkingInstance.actualLocaleIDName;

        if (!localeStyle)
        {
            fallbackLastOperationStatus
                                = LastOperationStatus.LOCALE_UNDEFINED_ERROR;
            return undefined;
        }

        fallbackLastOperationStatus = LastOperationStatus.NO_ERROR;

        return "en-US";
    }

    //----------------------------------
    //  lastOperationStatus
    //----------------------------------

    [Bindable("change")]

    /**
     *  @inheritDoc
     *
     *  @playerversion Flash 10.1
     *  @langversion 3.0
     *  @productversion Flash CS5
     *  @productversion Flex 4.5
     */
    override public function get lastOperationStatus():String
    {
        return g11nWorkingInstance ?
            g11nWorkingInstance.lastOperationStatus :
            fallbackLastOperationStatus;
    }

    //----------------------------------
    //  useFallback
    //----------------------------------

    [Bindable("change")]

    /**
     *  @private
     */
    override mx_internal function get useFallback():Boolean
    {
        return g11nWorkingInstance == null;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  dateStyle
    //----------------------------------

    [Bindable("change")]
    [Inspectable(category="General", enumeration="long,medium,short,none",
                                                        defaultValue="long")]

    /**
     *  The date style for this instance of the DateTimeFormatter.
     *
     *  The date style is used to retrieve a predefined time and locale
     *  specific formatting pattern from the operating system.
     *  When formatting a date, the <code>locale</code> style, the
     *  <code>timeStyle</code> and the <code>dateStyle</code> properties
     *  determine the format of the date.
     *
     *  The date style value can be set in the following three ways:
     *  assigning a value to <code>dateStyle</code> property,
     *  <code>dateTimePattern</code> property, or the dateStyle parameter in
     *  the <code>DateTimeFormatter()</code> constructor.
     *
     *  <p>Possible values for the timeStyle property are:</p>
     *
     *  <ul>
     *  <li><code>DateTimeStyle.LONG</code> </li>
     *  <li><code>DateTimeStyle.MEDIUM</code> </li>
     *  <li><code>DateTimeStyle.SHORT </code></li>
     *  <li><code>DateTimeStyle.NONE </code></li>
     *  <li><code>DateTimeStyle.CUSTOM </code></li>
     *  </ul>
     *
     *  @default <code>DateTimeStyle.LONG</code>
     *
     *  @throws ArgumentError if the assigned value is not a valid
     *          <code>DateTimeStyle</code> constant or is
     *          <code>DateTimeStyle.CUSTOM </code>.
     *  @throws TypeError if the <code>dateStyle</code> or
     *          <code>timeStyle</code> parameter is null.
     *
     *  @see #dateStyle
     *  @see #dateTimePattern
     *  @see #lastOperationStatus
     *  @see flash.globalization.DateTimeStyle
     *  @see #DateTimeFormatter()
     *
     *  @playerversion Flash 10.1
     *  @langversion 3.0
     *  @productversion Flex 4.5
     *  @productversion Flash CS5
     */
    public function get dateStyle():String
    {
        if (g11nWorkingInstance)
            return g11nWorkingInstance.getDateStyle();

        if (!localeStyle)
        {
            fallbackLastOperationStatus
                                = LastOperationStatus.LOCALE_UNDEFINED_ERROR;
            return undefined;
        }

        return fallbackFormatter.dateStyle;
    }

    public function set dateStyle(value:String):void
    {
        dateStyleOverride = value;

        if (g11nWorkingInstance)
        {
            g11nWorkingInstance.setDateTimeStyles(value, timeStyleOverride);
            dateTimePatternOverride = null;
        }
        else
        {
            if (!FallbackDateTimeFormatter.validDateTimeStyle(value))
                throw new TypeError();

            if (fallbackFormatter)
                fallbackFormatter.dateStyle = value;
            fallbackLastOperationStatus = LastOperationStatus.NO_ERROR;
        }

        update();
    }

    //----------------------------------
    //  dateTimePattern
    //----------------------------------

    [Bindable("change")]

    /**
     *  The pattern string used by the DateTimeFormatter object to format
     *  dates and times.
     *
     *  <p>This pattern can be set in one of three ways:</p>
     *
     *  <ol>
     *     <li>By the <code>dateStyle</code> and <code>timeStyle</code>
     *     parameters used in the constructor</li>
     *     <li>By the <code>dateSytl()</code> and <code>timeStyle</code>
     *     properties </li>
     *     <li>By the <code>dateTimePattern()</code> property.</li>
     *  </ol>
     *
     *  <p>If this property is assigned a value directly, as a side effect,
     *  the current time and date styles will be overriden and
     *  set to the value <code>DateTimeStyle.CUSTOM</code>.</p>
     *
     *  <p>For a description of the pattern syntax please see the
     *  <a href="flash.globalization.DateTimeFormatter.setDateTimePattern()">
     *  <code>flash.globalization.DateTimeFormatter.setDateTimePattern()
     *  </code></a> method.</p>
     *
     *  @return A string containing the pattern used by this
     *  DateTimeFormatter object to format dates and times.
     *
     *  @see DateTimeFormatter
     *  @see #dateStyle()
     *  @see #timeStyle()
     *
     *  @playerversion Flash 10.1
     *  @langversion 3.0
     *  @productversion Flex 4.5
     *  @productversion Flash CS5
     */
    public function get dateTimePattern():String
    {
        if (g11nWorkingInstance)
            return g11nWorkingInstance.getDateTimePattern();

        if (!localeStyle)
        {
            fallbackLastOperationStatus
                                = LastOperationStatus.LOCALE_UNDEFINED_ERROR;
            return undefined;
        }

        return fallbackFormatter.dateTimePattern;
    }

    public function set dateTimePattern(value:String):void
    {
        dateTimePatternOverride = value;

        if(g11nWorkingInstance)
            g11nWorkingInstance.setDateTimePattern(value);
        else
        {
            if (!value)
                throw new TypeError();

            if (fallbackFormatter)
                fallbackFormatter.dateTimePattern = value;
            fallbackLastOperationStatus = LastOperationStatus.NO_ERROR;
        }

        update();
    }

    //----------------------------------
    //  timeStyle
    //----------------------------------

    [Bindable("change")]
    [Inspectable(category="General", enumeration="long,medium,short,none",
                                                        defaultValue="long")]

    /**
     *  The time style for this instance of the DateTimeFormatter.
     *
     *  The time style is used to retrieve a predefined time and locale
     *  specific formatting pattern from the operating system.
     *  When formatting a date, the <code>locale</code> style, the
     *  <code>timeStyle</code> and the <code>dateStyle</code> properties
     *  determine the format of the date.
     *
     *  The time style value can be set in the following three ways:
     *  assigning a value to <code>timeStyle</code> property,
     *  <code>dateTimePattern</code> property, or the timeStyle parameter in
     *  the <code>DateTimeFormatter()</code> constructor.
     *
     *  <p>Possible values for the timeStyle property are:</p>
     *
     *  <ul>
     *  <li><code>DateTimeStyle.LONG</code></li>
     *  <li><code>DateTimeStyle.MEDIUM</code></li>
     *  <li><code>DateTimeStyle.SHORT</code></li>
     *  <li><code>DateTimeStyle.NONE</code></li>
     *  <li><code>DateTimeStyle.CUSTOM</code></li>
     *  </ul>
     *
     *  @default <code>DateTimeStyle.LONG</code>
     *
     *  @throws ArgumentError if the a not a valid <code>DateTimeStyle</code>
     *          constant or is <code>DateTimeStyle.CUSTOM </code>.
     *
     *  @throws TypeError if the <code>dateStyle</code> or
     *          <code>timeStyle</code> parameter is null.
     *
     *  @see #dateStyle
     *  @see #dateTimePattern
     *  @see flash.globalization.DateTimeStyle
     *  @see #DateTimeFormatter()
     *
     *  @playerversion Flash 10.1
     *  @langversion 3.0
     *  @productversion Flex 4.5
     *  @productversion Flash CS5
     */
    public function get timeStyle():String
    {
        if (g11nWorkingInstance)
            return g11nWorkingInstance.getTimeStyle();

        if (!localeStyle)
        {
            fallbackLastOperationStatus
                                = LastOperationStatus.LOCALE_UNDEFINED_ERROR;
            return undefined;
        }

        return fallbackFormatter.timeStyle;
    }

    public function set timeStyle(value:String):void
    {
        timeStyleOverride = value;

        if (g11nWorkingInstance)
        {
            g11nWorkingInstance.setDateTimeStyles(dateStyleOverride, value);
            dateTimePatternOverride = null;
        }
        else
        {
            if (!FallbackDateTimeFormatter.validDateTimeStyle(value))
                throw new TypeError();

            if (fallbackFormatter)
                fallbackFormatter.timeStyle = value;
            fallbackLastOperationStatus = LastOperationStatus.NO_ERROR;
        }

        update();
    }

    //----------------------------------
    //  useUTC
    //----------------------------------

    /**
     *  @private
     *  Flag to indicate if UTC is used.
     *
     *  true: format in UTC. false: format in non-UTC
     */
    private var _useUTC:Boolean = false;

    [Bindable("change")]

    /**
     *  A boolean flag to control whethor the local or the UTC date and time
     *  values are used when the formatting a date.
     *
     *  If <code>useUTC</code> is set to true then the UTC values are used.
     *  If the value is false, then the date time values of the operating
     *  system's current time zone is used.
     *
     *  @see #format
     *
     *  @playerversion Flash 10.1
     *  @langversion 3.0
     *  @productversion Flash CS5
     *  @productversion Flex 4.5
     */
    public function get useUTC():Boolean
    {
        return _useUTC;
    }

    public function set useUTC(value:Boolean):void
    {
        _useUTC = value;

        update();
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override mx_internal function createWorkingInstance():void
    {
        if (!localeStyle)
        {
            fallbackLastOperationStatus
                                = LastOperationStatus.LOCALE_UNDEFINED_ERROR;
            g11nWorkingInstance = null;
            return;
        }

        if (enforceFallback)
        {
            fallbackInstantiate();
            g11nWorkingInstance = null;
            return;
        }

        g11nWorkingInstance = new flash.globalization.DateTimeFormatter(
            localeStyle, dateStyleOverride, timeStyleOverride);
        if (g11nWorkingInstance
            && (g11nWorkingInstance.lastOperationStatus
                                != LastOperationStatus.UNSUPPORTED_ERROR))
        {
            if (dateTimePatternOverride)
                g11nWorkingInstance.setDateTimePattern(dateTimePatternOverride);
            return;
        }

        fallbackInstantiate();
        g11nWorkingInstance = null;

        if (fallbackFormatter.fallbackLastOperationStatus
                                            == LastOperationStatus.NO_ERROR)
        {
            fallbackFormatter.fallbackLastOperationStatus
                                = LastOperationStatus.USING_FALLBACK_WARNING;
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    [Bindable("change")]

    /**
     *  Formats a display string for a Date object in either the user's local
     *  time or UTC time.
     *
     *  A <code>Date</code> object has two sets of date and time values,
     *  those in the user's local time (date, day, fullYear, hours, minutes,
     *  month, and seconds) and those in UTC time (dateUTC, dayUTC,
     *  fullYearUTC, hoursUTC, minutesUTC, monthUTC, and secondsUTC).
     *  The boolean property <code>useUTC</code> controls which set of
     *  date and time components are used when formatting the date.
     *  The formatting will be done using the conventions of the locale as
     *  set by the <code>locale</code> style property and the
     *  <code>dateStyle</code> and <code>timeStyle</code> properties, or the
     *  <code>dateTimePattern</code>, specified for this
     *  <code>DateTimeFormatter</code> instance.
     *
     *
     *  @param value A <code>Date</code> value to be formatted.
     *  @return A formatted string representing the date or time value.
     *
     *  @see #dateStyle
     *  @see #timeStyle
     *  @see #dateTimePattern
     *  @see DateTimeFormatter
     *
     *  @playerversion Flash 10.1
     *  @langversion 3.0
     *  @productversion Flex 4.5
     *  @productversion Flash CS5
     */
    public function format(value:Object):String
    {
        if (value == null)
            return null;

        const dateTime:Date = (value is Date) ?
                                            (value as Date) : new Date(value);

        if (g11nWorkingInstance)
        {
            return _useUTC ?
                g11nWorkingInstance.formatUTC(dateTime) :
                g11nWorkingInstance.format(dateTime);
        }

        if (!localeStyle)
        {
            fallbackLastOperationStatus
                                = LastOperationStatus.LOCALE_UNDEFINED_ERROR;
            return undefined;
        }

        fallbackLastOperationStatus = LastOperationStatus.NO_ERROR;

        return _useUTC ?
            fallbackFormatter.formatUTC(dateTime) :
            fallbackFormatter.format(dateTime);
    }

    [Bindable("change")]

    /**
     *  Retrieves a list of localized strings containing the month names for
     *  the current calendar system.
     *
     *  The first element in the list is the name for the first month of the
     *  year.
     *
     *  @param nameStyle Indicates the style of name string to be used.
     *          Valid values are:
     *          <ul>
     *              <li><code>DateTimeNameStyle.FULL</code></li>
     *              <li><code>DateTimeNameStyle.LONG_ABBREVIATION</code>
     *                  </li>
     *              <li><code>DateTimeNameStyle.SHORT_ABBREVIATION</code>
     *                  </li>
     *          </ul>
     *  @param context A code indicating the context in which the formatted
     *          string will be used.
     *          This context will only make a difference for certain
     *          locales.
     *          Valid values are:
     *          <ul>
     *              <li><code>DateTimeNameContext.FORMAT</code></li>
     *              <li><code>DateTimeNameContext.STANDALONE</code></li>
     *          </ul>
     *
     *  @return A vector of localized strings containing the month names for
     *          the specified locale, name style and context.
     *          The first element in the vector, at index 0, is the name for
     *          the first month of the year; the next element is the name
     *          for the second month of the year; and so forth.
     *  @throws TypeError if the <code>nameStyle</code> or
     *          <code>context</code> parameter is null.
     *
     *  @see flash.globalization.DateTimeNameContext
     *  @see flash.globalization.DateTimeNameStyle
     *
     *  @playerversion Flash 10.1
     *  @langversion 3.0
     *  @productversion Flex 4.5
     *  @productversion Flash CS5
     */
    public function getMonthNames(nameStyle:String = "full",
                            context:String = "standalone"):Vector.<String>
    {
        if (g11nWorkingInstance)
            return g11nWorkingInstance.getMonthNames(nameStyle, context);

        if (!localeStyle)
        {
            fallbackLastOperationStatus
                                = LastOperationStatus.LOCALE_UNDEFINED_ERROR;
            return undefined;
        }

        fallbackLastOperationStatus = LastOperationStatus.NO_ERROR;

        return fallbackFormatter.getMonthNames(nameStyle, context);
    }

    [Bindable("change")]

    /**
     *  Retrieves a list of localized strings containing the names of
     *  weekdays for the current calendar system.
     *
     *  The first element in the list represents the name for Sunday.
     *
     *  @param nameStyle Indicates the style of name string to be used.
     *          Valid values are:
     *          <ul>
     *              <li><code>DateTimeNameStyle.FULL</code></li>
     *              <li><code>DateTimeNameStyle.LONG_ABBREVIATION</code>
     *                  </li>
     *              <li><code>DateTimeNameStyle.SHORT_ABBREVIATION</code>
     *                  </li>
     *          </ul>
     *  @param context A code indicating the context in which the formatted
     *          string will be used.
     *          This context only applies for certain locales where the name
     *          of a month changes depending on the context.
     *          For example, in Greek the month names are different if they
     *          are displayed alone versus displayed along with a day.
     *          Valid values are:
     *          <ul>
     *              <li><code>DateTimeNameContext.FORMAT</code></li>
     *              <li><code>DateTimeNameContext.STANDALONE</code></li>
     *          </ul>
     *
     *  @return A vector of localized strings containing the month names for
     *          the specified locale, name style and context.
     *          The first element in the vector, at index 0, is the name for
     *          Sunday; the next element is the name for Monday; and so
     *          forth.
     *  @throws TypeError if the <code>nameStyle</code> or
     *          <code>context</code> parameter is null.
     *
     *  @see flash.globalization.DateTimeNameContext
     *  @see flash.globalization.DateTimeNameStyle
     *
     *  @playerversion Flash 10.1
     *  @langversion 3.0
     *  @productversion Flex 4.5
     *  @productversion Flash CS5
     */
    public function getWeekdayNames(nameStyle:String = "full",
                            context:String = "standalone"):Vector.<String>
    {
        if (g11nWorkingInstance)
            return g11nWorkingInstance.getWeekdayNames(nameStyle, context);

        if (!localeStyle)
        {
            fallbackLastOperationStatus
                                = LastOperationStatus.LOCALE_UNDEFINED_ERROR;
            return undefined;
        }

        fallbackLastOperationStatus = LastOperationStatus.NO_ERROR;

        return fallbackFormatter.getWeekdayNames(nameStyle, context);
    }

    [Bindable("change")]

    /**
     *  Returns an integer corresponding to the first day of the week for
     *  this locale and calendar system.
     *
     *  A value of 0 corresponds to Sunday, 1 corresponds to Monday and so
     *  on, with 6 corresponding to Saturday.
     *
     *  @return An integer corresponding to the first day of the week for
     *  this locale and calendar system.
     *
     *  @playerversion Flash 10.1
     *  @langversion 3.0
     *  @productversion Flex 4.5
     *  @productversion Flash CS5
     */
    public function getFirstWeekday():int
    {
        if (g11nWorkingInstance)
            return g11nWorkingInstance.getFirstWeekday();

        if (!localeStyle)
        {
            fallbackLastOperationStatus
                                = LastOperationStatus.LOCALE_UNDEFINED_ERROR;
            return undefined;
        }

        fallbackLastOperationStatus = LastOperationStatus.NO_ERROR;

        return 0;
    }

    /**
     *  @copy spark.utils.Collator#getAvailableLocaleIDNames
     *
     *  @playerversion Flash 10.1
     *  @langversion 3.0
     *  @productversion Flash CS5
     *  @productversion Flex 4.5
     */
    public static function getAvailableLocaleIDNames():Vector.<String>
    {
        const locales:Vector.<String>
            = flash.globalization.DateTimeFormatter.getAvailableLocaleIDNames();

        return locales ? locales : new Vector.<String>["en-US"];
    }

    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Imaginary constructor of FallbackCollator.
     */
    private function fallbackInstantiate():void
    {
        fallbackFormatter = new FallbackDateTimeFormatter();

        if (dateStyleOverride)
            fallbackFormatter.dateStyle = dateStyleOverride;

        if (timeStyleOverride)
            fallbackFormatter.timeStyle = timeStyleOverride;

        if (dateTimePatternOverride)
            fallbackFormatter.dateTimePattern = dateTimePatternOverride;

        fallbackLastOperationStatus = LastOperationStatus.NO_ERROR;
    }
}
}

import flash.globalization.DateTimeNameStyle;
import flash.globalization.DateTimeStyle;

import spark.globalization.LastOperationStatus;

/**
 *  @private
 *  FallbackDateTimeFormatter.
 */
final class FallbackDateTimeFormatter
{
    //----------------------------------
    // Class constants
    //----------------------------------

    private static const SHORT_DATE_PATTERN:String = "m/d/yyyy";
    private static const MEDIUM_DATE_PATTERN:String = "dddd, mmmm d, yyyy ";
    private static const LONG_DATE_PATTERN:String = "dddd, mmmm d, yyyy ";
    private static const NONE_DATE_PATTERN:String = "";

    private static const SHORT_TIME_PATTERN:String = "hh:mm a";
    private static const MEDIUM_TIME_PATTERN:String = "hh:mm:ss a";
    private static const LONG_TIME_PATTERN:String = "hh:mm:ss a";
    private static const NONE_TIME_PATTERN:String = "";

    private static const WEEKDAY_LABELS:Vector.<String> = new <String>
        ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday",
                                                                    "Saturday"];
    private static const WEEKDAY_LABELS_LONG_ABB:Vector.<String> = new <String>
        ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    private static const WEEKDAY_LABELS_SHORT_ABB:Vector.<String> = new <String>
        ["S", "M", "T", "W", "T", "F", "S"];

    private static const MONTH_LABELS:Vector.<String> = new <String>
        ["January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"];

    private static const MONTH_LABELS_LONG_ABB:Vector.<String> = new <String>
        ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
            "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

    private static const MONTH_LABELS_SHORT_ABB:Vector.<String> = new <String>
        ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
            "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

    //----------------------------------
    // Constructor
    //----------------------------------

    public function FallbackDateTimeFormatter()
    {
        super();
    }

    //----------------------------------
    // Variables
    //----------------------------------

    private var utc:Boolean;

    private var space:String = "";

    private var dateString:String;

    private var timeString:String;
    private var localTime:String;


    //----------------------------------
    // Properties
    //----------------------------------

    // lastOperationStatus for the imaginal fallback class
    public var fallbackLastOperationStatus:String;

    private var _timeStyle:String;

    public function set timeStyle(value:String):void
    {
        if (value)
            _timeStyle = value;
    }

    public function get timeStyle():String
    {
        return _timeStyle;
    }

    private var _dateStyle:String;

    public function set dateStyle(value:String):void
    {
        if (value)
            _dateStyle = value;
    }

    public function get dateStyle():String
    {
        return _dateStyle;
    }

    private var _dateTimePatternString:String;

    public function get dateTimePattern():String
    {
        if (dateStyle == DateTimeStyle.SHORT )
            dateString = SHORT_DATE_PATTERN;
        else if (dateStyle == DateTimeStyle.MEDIUM)
            dateString = LONG_DATE_PATTERN;
        else if (dateStyle == DateTimeStyle.NONE)
            dateString = NONE_DATE_PATTERN;
        else
            dateString = LONG_DATE_PATTERN;

        if (timeStyle == DateTimeStyle.SHORT)
            timeString = SHORT_TIME_PATTERN;
        else if (timeStyle == DateTimeStyle.MEDIUM)
            timeString = LONG_TIME_PATTERN;
        else if (timeStyle == DateTimeStyle.NONE)
            timeString = NONE_TIME_PATTERN;
        else
            timeString =LONG_TIME_PATTERN;

        return (dateString + timeString);
    }

    public function set dateTimePattern(value:String):void
    {
        _dateTimePatternString = value;
        fallbackLastOperationStatus = LastOperationStatus.UNSUPPORTED_ERROR;
    }

    //----------------------------------
    // Methods
    //----------------------------------

    public function format(dateTime:Date):String
    {
        utc= false;
        return (returnDate(dateTime) + space+ returnTime(dateTime));
    }

    public function formatUTC(dateTime:Date):String
    {
        utc= true;
        return (returnDate(dateTime) + space+ returnTime(dateTime));
    }

    public function getMonthNames(nameStyle:String = "full",
                            context:String = "standalone"):Vector.<String>
    {
        if (nameStyle == DateTimeNameStyle.SHORT_ABBREVIATION)
            return MONTH_LABELS_SHORT_ABB;
        else if (nameStyle == DateTimeNameStyle.LONG_ABBREVIATION)
            return MONTH_LABELS_LONG_ABB;
        else
            return MONTH_LABELS;
    }

    public function getWeekdayNames(nameStyle:String = "full",
                            context:String = "standalone"):Vector.<String>
    {
        if (nameStyle == DateTimeNameStyle.SHORT_ABBREVIATION)
            return WEEKDAY_LABELS_SHORT_ABB;
        else if (nameStyle == DateTimeNameStyle.LONG_ABBREVIATION)
            return WEEKDAY_LABELS_LONG_ABB;
        else
            return WEEKDAY_LABELS;
    }

    public static function validDateTimeStyle(value:String):Boolean
    {
        return value && ((value == DateTimeStyle.LONG)
                        || (value == DateTimeStyle.MEDIUM)
                        || (value == DateTimeStyle.SHORT)
                        || (value == DateTimeStyle.NONE));
    }

    //----------------------------------
    // Private Methods
    //----------------------------------

    private function returnDate(dateTime:Date):String
    {
        if (isNaN(dateTime.fullYear))
            return "";
        else
        {
            if (dateStyle == DateTimeStyle.SHORT)
            {
                space = " ";
                return shortDate(dateTime);
            }
            else if (dateStyle == DateTimeStyle.MEDIUM)
            {
                space = " ";
                return longDate(dateTime);
            }
            else if (dateStyle == DateTimeStyle.NONE)
            {
                space = "";
                return "";
            }
            else
            {
                space = " ";
                return longDate(dateTime);
            }
        }
    }

    private function returnTime(dateTime:Date):String
    {
        if (isNaN(dateTime.hours))
            return "";
        else
        {
            if (timeStyle == DateTimeStyle.SHORT)
                return shortTime(dateTime);
            else if (timeStyle == DateTimeStyle.MEDIUM)
                return longTime(dateTime);
            else if (timeStyle == DateTimeStyle.NONE)
            {
                space = "";
                return "";
            }
            else
                return longTime(dateTime);
        }
    }

    private function shortDate(dateTime:Date):String
    {
        if (!utc)
        {
            return (doubleDigitFormat(dateTime.getMonth() + 1)) + "/"
                + doubleDigitFormat(dateTime.getDate()) + "/"
                + doubleDigitFormat(dateTime.getFullYear());
        }
        else
        {
            return (doubleDigitFormat(dateTime.getUTCMonth() + 1)) + "/"
                + doubleDigitFormat(dateTime.getUTCDate()) + "/"
                + doubleDigitFormat(dateTime.getUTCFullYear());
        }
    }

    private function longDate(dateTime:Date):String
    {
        if (!utc)
        {
            return (WEEKDAY_LABELS[dateTime.getDay()] + ","
                + MONTH_LABELS[dateTime.getMonth()])
                + dateTime.getDate() + ","
                + dateTime.getFullYear();
        }
        else
        {
            return (WEEKDAY_LABELS[dateTime.getUTCDay()] + ","
                + MONTH_LABELS[dateTime.getUTCMonth()])
                + dateTime.getUTCDate() + ","
                + dateTime.getUTCFullYear();
        }
    }

    private function shortTime(dateTime:Date):String
    {
        if (!utc)
        {
            localTime = getUSClockTime(
                                dateTime.getHours(), dateTime.getMinutes());
        }
        else
        {
            localTime = getUSClockTime(
                            dateTime.getUTCHours(), dateTime.getUTCMinutes());
        }
        return localTime + " " + formatAMPM(dateTime);
    }

    private function longTime(dateTime:Date):String
    {
        if (!utc)
        {
            localTime = getUSClockTime(
                                dateTime.getHours(), dateTime.getMinutes());
            return localTime + ":" + doubleDigitFormat(dateTime.getSeconds())
                + " " + formatAMPM(dateTime);
        }
        else
        {
            localTime = getUSClockTime(
                            dateTime.getUTCHours(), dateTime.getUTCMinutes());
            return localTime + ":" + doubleDigitFormat(dateTime.getUTCSeconds())
                + " " + formatAMPM(dateTime);
        }
    }

    private function getUSClockTime(hrs:uint, mins:uint):String
    {
        const minLabel:String = doubleDigitFormat(mins);

        if (hrs > 12)
            hrs = hrs-12;
        else if (hrs == 0)
            hrs = 12;

        return doubleDigitFormat(hrs) + ":" + minLabel;
    }

    private function doubleDigitFormat(num:uint):String
    {
        return ((num < 10) ? "0" : "") + String(num);
    }

    private function formatAMPM(dateTime:Date):String
    {
        return (dateTime.getHours() < 12) ? "AM" : "PM";
    }
}
