using System;
using System.IO;
using System.Xml;
using System.Xml.Schema;
using System.Xml.Serialization;
using KafkaXmlConsumer.Models;

namespace KafkaXmlConsumer
{
    public class XmlProcessor
    {
        private readonly XmlSerializer _serializer;
        private readonly XmlSchemaSet _schemaSet;

        public XmlProcessor(string xsdFilePath)
        {
            _serializer = new XmlSerializer(typeof(Crt));
            _schemaSet = new XmlSchemaSet();
            
            if (!string.IsNullOrEmpty(xsdFilePath) && File.Exists(xsdFilePath))
            {
                _schemaSet.Add(null, xsdFilePath);
            }
            else
            {
                throw new FileNotFoundException($"XSD file not found at path: {xsdFilePath}");
            }
        }

        public Crt Parse(string xml)
        {
            var settings = new XmlReaderSettings
            {
                ValidationType = ValidationType.Schema,
                Schemas = _schemaSet
            };

            settings.ValidationEventHandler += (sender, args) =>
            {
                if (args.Severity == XmlSeverityType.Error)
                {
                    throw new XmlSchemaValidationException($"XML Schema Validation Error: {args.Message}", args.Exception, args.Exception.LineNumber, args.Exception.LinePosition);
                }
            };

            using (var stringReader = new StringReader(xml))
            using (var xmlReader = XmlReader.Create(stringReader, settings))
            {
                return (Crt)_serializer.Deserialize(xmlReader);
            }
        }
    }
}
